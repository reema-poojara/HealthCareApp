//
//  RemoteRecordsRepositoryTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-31.
//

import XCTest
@testable import YourHealthNSDemo

@MainActor
final class RemoteRecordsRepositoryTests: XCTestCase {

    func testFetchRecordSuccessfully() async throws {
        
        let data = makeValidBundleJson()
        let repository = makeRepository(data:data,statusCode:200)
        
        let records = try await repository.fetchRecords()
        
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.id, "report-001")
        XCTAssertEqual(records.first?.title, "Complete Blood Count")
    }
    
    func testFetchRecordsMapObservation() async throws {
        let repository = makeRepository(data:makeValidBundleJson(),statusCode:200)
     
        let records = try await repository.fetchRecords()
        
        let record = try XCTUnwrap(records.first)
        
        XCTAssertEqual(record.vitals.count, 1)
        XCTAssertEqual(record.vitals.first?.name, "Hemoglobin")
        XCTAssertEqual(record.vitals.first?.value, "14.5")
        XCTAssertEqual(record.vitals.first?.unit, "g/dL")
        XCTAssertEqual(record.vitals.first?.referenceRange,"12 g/dL - 16 g/dL")
    }
    
    func testFetchStandalonDiagnosticReport() async throws {
        
        let json = """
            {
                "resourceType": "DiagnosticReport",
                "id":"report-001",
                "status":"final",
                "code":{
                    "text":"Complete blood count"
                }
            }
            """
        
        let repository = makeRepository(data:json.data(using: .utf8)!,statusCode:200)
        
        let record = try await repository.fetchRecords()
        
        XCTAssertEqual(record.count, 1)
        XCTAssertEqual(record.first?.id, "report-001")
        XCTAssertEqual(record.first?.title, "Complete blood count")
    }
    
    func testFetchRecordsWith404Error() async throws {
        let repository = makeRepository(data:Data(),statusCode:404)
        
        do{
            _ = try await repository.fetchRecords()
            XCTFail("Expected HTTP 404 error")
        } catch let error as APIError {
            guard case .httpsError(let statusCode) = error else {
                return XCTFail("Expected HTTP error")
            }
            XCTAssertEqual(statusCode, 404)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testRecordsWith500Error() async throws {
        let repository = makeRepository(data:Data(),statusCode:500)
        
        do{
            _ = try await repository.fetchRecords()
            XCTFail("Expected HTTP 500 error")
        } catch let error as APIError {
            guard case .httpsError(let statusCode) = error else {
                return XCTFail("Expected HTTP error")
            }
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testFetchRecordWithInvalidJSON() async throws {
        let json = Data("""
            {
            "resourceType":
            }
            """.utf8
        )
        
        let repository = makeRepository(data:json,statusCode:200)
        
        do{
            _ = try await repository.fetchRecords()
            XCTFail("Expected decoding error")
        } catch let error as APIError {
            guard case .decodingFailed = error else {
                return  XCTFail("Expected decoding failure")
            }
        }catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecordWithUnsupportedResourceType() async throws {
        let json = """
            {
                "resourceType": "Patient",
                "id":"patient-001",
                "status":"not final"
            }
            """
        let repository = makeRepository(data:Data(json.utf8),statusCode:200)
        
        do{
            _ = try await repository.fetchRecords()
            XCTFail("Expected missing resource error")
        } catch let error as APIError {
            guard case .missingResource(let resource) = error else {
                return XCTFail("Expected missing resource error")
            }
            XCTAssertEqual(resource, "Expected FHIR Bundle or resource")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchRecordWithEmptyBundle() async throws {
        let json = """
            {
                "resourceType": "Bundle",
                "id":"101",
                "type":"collection",
                "entry":[]
            }
            """
        let repository = makeRepository(data:Data(json.utf8),statusCode:200)
        
        let records = try await repository.fetchRecords()
        
        XCTAssertTrue(records.isEmpty)
    }
    
    private func makeRepository(data:Data,statusCode:Int) -> RemoteRecordsRepository {
        
        let configurration = URLSessionConfiguration.ephemeral
        
        configurration.protocolClasses = [
            MockURLProtocol.self
    ]
        let session = URLSession(configuration: configurration)
        
        let apiClient = APIClient(session: session)
        
        MockURLProtocol.requestHandler = { request in
         
            guard let url = request.url else {
                throw APIError.invalidURL
            }
            
            let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTTP/1.1", headerFields: [
                "content-Type":"application/fhir+json"
            ])!
            
            return (response,data)
        }
        return RemoteRecordsRepository(apiClient: apiClient)
    }
    
    private func makeValidBundleJson() -> Data {
        let json = """
                {
                    "resourceType": "Bundle",
                    "id": "bundle-001",
                    "type": "collection",
                    "entry": [
                        {
                            "fullUrl": "Observation/obs-001",
                            "resource": {
                                "resourceType": "Observation",
                                "id": "obs-001",
                                "status": "final",
                                "code": {
                                    "text": "Hemoglobin"
                                },
                                "valueQuantity": {
                                    "value": 14.5,
                                    "unit": "g/dL"
                                },
                                "referenceRange": [
                                    {
                                        "low": {
                                            "value": 12.0,
                                            "unit": "g/dL"
                                        },
                                        "high": {
                                            "value": 16.0,
                                            "unit": "g/dL"
                                        }
                                    }
                                ]
                            }
                        },
                        {
                            "fullUrl": "DiagnosticReport/report-001",
                            "resource": {
                                "resourceType": "DiagnosticReport",
                                "id": "report-001",
                                "status": "final",
                                "code": {
                                    "text": "Complete Blood Count"
                                },
                                "result": [
                                    {
                                        "reference": "Observation/obs-001"
                                    }
                                ]
                            }
                        }
                    ]
                }
                """
        return Data(json.utf8)
    }
    func testFetchRecordsReturnsFHIRDiagnosticReports() async throws {

            // Given: A mocked FHIR response
            let json = """
            {
                "resourceType": "Bundle",
                "type": "collection",
                "entry": []
            }
            """

            let configuration = URLSessionConfiguration.ephemeral
            configuration.protocolClasses = [MockURLProtocol.self]

            MockURLProtocol.requestHandler = { request in

                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/fhir+json"]
                )!

                return (response, Data(json.utf8))
            }

            let session = URLSession(configuration: configuration)
            let apiClient = APIClient(session: session)

            let repository = RemoteRecordsRepository(apiClient: apiClient)

            // When
            let records = try await repository.fetchRecords()

            // Then
            XCTAssertTrue(records.isEmpty)
        }
    
    func testFetchRecordsWithServerError() async throws {

        // Given: An unsuccessful server response
        let repository = makeRepository(data: Data(),statusCode: 500)

        // When: Fetching records
        do {
            _ = try await repository.fetchRecords()

            XCTFail("Expected HTTP error")

        } catch let error as APIError {

            guard case .httpsError(let statusCode) = error else {
                return XCTFail("Expected HTTP error")
            }

            XCTAssertEqual(statusCode, 500)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRecordsWithInvalidJSON() async throws {

        // Given: Invalid JSON from the server
        let invalidJSON = """
        {
            "resourceType": "Bundle",
            "entry": [
                {
                    "resource": {
                        "resourceType":
                    }
                }
            ]
        }
        """

        let repository = makeRepository(
            data: Data(invalidJSON.utf8),
            statusCode: 200
        )

        // When: Fetching records
        do {
            _ = try await repository.fetchRecords()

            XCTFail("Expected decoding error")

        } catch let error as APIError {

            guard case .decodingFailed = error else {
                return XCTFail("Expected decoding error, got \(error)")
            }

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    func testFetchRecordsWithEmptyBundle() async throws {

        let json = """
        {
            "resourceType": "Bundle",
            "type": "collection",
            "entry": []
        }
        """

        let repository = makeRepository(
            data: Data(json.utf8),
            statusCode: 200
        )

        let records = try await repository.fetchRecords()

        XCTAssertTrue(records.isEmpty)
    }
    func testFetchRecordsWithReportWithoutID() async throws {

        let json = """
        {
            "resourceType": "Bundle",
            "type": "collection",
            "entry": [
                {
                    "resource": {
                        "resourceType": "DiagnosticReport",
                        "status": "final",
                        "code": {
                            "text": "Complete Blood Count"
                        }
                    }
                }
            ]
        }
        """

        let repository = makeRepository(
            data: Data(json.utf8),
            statusCode: 200
        )

        let records = try await repository.fetchRecords()

        XCTAssertTrue(records.isEmpty)
    }
    func testFetchRecordsWithNetworkFailure() async throws {

        // Given
        MockURLProtocol.error = URLError(.notConnectedToInternet)

        let repository = makeRepository(data: Data(),statusCode: 200)

        // When / Then
        do {
            _ = try await repository.fetchRecords()

            XCTFail("Expected network error")

        } catch let error as APIError {

            guard case .networkError = error else {
                return XCTFail("Expected network error, got \(error)")
            }

        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        MockURLProtocol.error = nil
    }
}

//MARK: - Mock URL Protocol

private final class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var error: Error?
    nonisolated(unsafe) static var requestHandler:
            ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
            true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
    }
    
    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    override func stopLoading() {
        
    }
//    defer {
//        MockURLProtocol.error = nil
//    }   
    
}
