//
//  APIClientTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-31.
//

import XCTest
@testable import YourHealthNSDemo

final class APIClientTests: XCTestCase {

    // MARK: - Tear Down

    override func tearDown() {
        MockAPIURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - Test 1: Successful Raw Data Request

    func testGetRawDataSuccessfully() async throws {

        let expectedData = Data("FHIR Response".utf8)

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 200)
            return (response, expectedData)
        }

        let client = makeAPIClient()

        let url = try XCTUnwrap(URL(string: "https://fhir.healthit.gov/open"))

        let result = try await client.getRawData(from: url)
        
        XCTAssertEqual(result, expectedData)
    }

    // MARK: - Test 2: Successful JSON Decoding

    func testGetDecodesJSONSuccessfully() async throws {

        let json = """
        {
            "name": "Complete Blood Count",
            "status": "final"
        }
        """

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 200)

            return (response, Data(json.utf8))
        }

        let client = makeAPIClient()

        let url = try XCTUnwrap(
            URL(string: "https://fhir.healthit.gov/open")
        )

        let result: TestResponse = try await client.get(from: url)

        XCTAssertEqual(result.name, "Complete Blood Count")
        XCTAssertEqual(result.status, "final")
    }

    // MARK: - Test 3: HTTP 404 Error

    func testGetRawDataWith404Error() async {

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 404)
            return (response, Data())
        }

        let client = makeAPIClient()
        let url = URL(string: "https://fhir.healthit.gov/open")!

        do {
            _ = try await client.getRawData(from: url)

            XCTFail("Expected HTTP 404 error")

        } catch let error as APIError {

            guard case .httpsError(let code) = error else {
                return XCTFail("Expected HTTPS error")
            }

            XCTAssertEqual(code, 404)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 4: HTTP 500 Error

    func testGetRawDataWith500Error() async {

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 500)

            return (response, Data())
        }

        let client = makeAPIClient()
        let url = URL(string: "https://fhir.healthit.gov/open")!

        do {
            _ = try await client.getRawData(from: url)

            XCTFail("Expected HTTP 500 error")

        } catch let error as APIError {

            guard case .httpsError(let code) = error else {
                return XCTFail("Expected HTTPS error")
            }

            XCTAssertEqual(code, 500)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 5: Network Failure

    func testGetRawDataWithNetworkFailure() async {

        MockAPIURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        let client = makeAPIClient()
        let url = URL(string: "https://fhir.healthit.gov/open")!

        do {
            _ = try await client.getRawData(from: url)

            XCTFail("Expected network error")

        } catch let error as APIError {

            guard case .networkError(let underlyingError) = error else {
                return XCTFail("Expected networkError, received: \(error)")
            }

            let urlError = underlyingError as? URLError

            XCTAssertEqual(urlError?.code,.notConnectedToInternet)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 6: Invalid JSON

    func testGetWithInvalidJSON() async {

        let invalidJSON = Data("{ invalid json".utf8)

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 200)

            return (response, invalidJSON)
        }

        let client = makeAPIClient()
        let url = URL(string: "https://fhir.healthit.gov/open")!

        do {
            let _: TestResponse = try await client.get(from: url)

            XCTFail("Expected decoding error")

        } catch let error as APIError {

            guard case .decodingFailed = error else {
                return XCTFail("Expected decoding failure")
            }

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 7: Generic GET HTTP Error

    func testGetWithHTTPError() async {

        MockAPIURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(request: request,statusCode: 404)

            return (response, Data("{}".utf8))
        }

        let client = makeAPIClient()
        let url = URL(string: "https://fhir.healthit.gov/open")!

        do {
            let _: TestResponse = try await client.get(from: url)

            XCTFail("Expected HTTP error")

        } catch let error as APIError {

            guard case .httpsError(let code) = error else {
                return XCTFail("Expected HTTPS error")
            }

            XCTAssertEqual(code, 404)

        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 8: Verify Request Headers

    func testGetRawDataUsesCorrectRequestHeaders() async throws {

        let expectedData = Data("Success".utf8)

        MockAPIURLProtocol.requestHandler = { request in

            XCTAssertEqual(request.httpMethod, "GET")

            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Accept"),
                "application/fhir+json, application/json"
            )

            XCTAssertEqual(
                request.value(forHTTPHeaderField: "Authorization"),
                "Bearer test-token"
            )

            let response = self.makeHTTPResponse(request: request,statusCode: 200)

            return (response, expectedData)
        }

        let client = makeAPIClient()

        let url = URL(string: "https://fhir.healthit.gov/open")!

        let result = try await client.getRawData(
            from: url,
            headers: [
                "Authorization": "Bearer test-token"
            ]
        )

        XCTAssertEqual(result, expectedData)
    }

    // MARK: - Test 9: Generic GET Method

    func testGenericGetUsesGETMethod() async throws {

        let json = """
        {
            "name": "CBC",
            "status": "final"
        }
        """

        MockAPIURLProtocol.requestHandler = { request in

            XCTAssertEqual(request.httpMethod, "GET")

            let response = self.makeHTTPResponse(request: request,statusCode: 200)

            return (response, Data(json.utf8))
        }

        let client = makeAPIClient()

        let url = URL(string: "https://fhir.healthit.gov/open")!

        let result: TestResponse = try await client.get(from: url)

        XCTAssertEqual(result.name, "CBC")
        XCTAssertEqual(result.status, "final")
    }

    // MARK: - Helper: Create APIClient

    private func makeAPIClient() -> APIClient {

        let configuration = URLSessionConfiguration.ephemeral

        configuration.protocolClasses = [
            MockAPIURLProtocol.self
        ]

        let session = URLSession(
            configuration: configuration
        )

        return APIClient(session: session)
    }

    // MARK: - Helper: HTTP Response

    private func makeHTTPResponse(request: URLRequest,statusCode: Int) -> HTTPURLResponse {

        HTTPURLResponse(url: request.url!,statusCode: statusCode,httpVersion: "HTTP/1.1",headerFields: [
                "Content-Type": "application/json"
            ]
        )!
    }
}

// MARK: - Test Response Model

private struct TestResponse: Decodable {

    let name: String
    let status: String
}

// MARK: - Mock URL Protocol

private final class MockAPIURLProtocol: URLProtocol {

    static var requestHandler:((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {

        guard let handler = Self.requestHandler else {

            client?.urlProtocol(self,didFailWithError: URLError(.badServerResponse))
            return
        }

        do {

            let (response, data) = try handler(request)

            client?.urlProtocol(self,didReceive: response,cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self,didLoad: data)
            client?.urlProtocolDidFinishLoading(self)

        } catch {

            client?.urlProtocol(self,didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
