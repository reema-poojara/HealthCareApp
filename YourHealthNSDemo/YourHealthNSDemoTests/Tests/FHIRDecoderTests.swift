//
//  FHIRDecoderTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-31.
//

import XCTest
@testable import YourHealthNSDemo

@MainActor
final class FHIRDecoderTests: XCTestCase {

  func testDecodeResourceSuccessfully() throws {
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
      
      let data = Data(json.utf8)
      
      let resource = try FHIRDecoder.decodeResource(from: data)
      
      XCTAssertEqual(resource.resourceType, "DiagnosticReport")
      XCTAssertEqual(resource.id, "report-001")
      XCTAssertEqual(resource.status, "final")
      XCTAssertEqual(resource.code?.displayName, "Complete blood count")
    }

    func testDecodeObservationSuccessfully() throws {
        let json = """
                {
                    "resourceType": "Observation",
                    "id":"obs-001",
                    "status":"final",
                    "code":{
                        "text":"Hemoglobin"
                    },
                    "valueQuantity": {
                        "value":14.5,
                        "unit":"g/dL"
                    }
                }
            """
        let data = Data(json.utf8)
        
        let resource = try FHIRDecoder.decodeResource(from: data)
        XCTAssertEqual(resource.resourceType, "Observation")
        XCTAssertEqual(resource.id, "obs-001")
        XCTAssertEqual(resource.code?.displayName, "Hemoglobin")
        XCTAssertEqual(resource.valueQuantity?.value, 14.5)
        XCTAssertEqual(resource.valueQuantity?.unit, "g/dL")
    }
    func testDecodeBundleSuccessfully() throws {
        let json = """
            {
                "resourceType": "Bundle",
                "id":"101",
                "type":"collection",
                "entry":[
                    {
                        "fullUrl":"https://example.com/base/DiagnosticReport/101",
                        "resource": {
                                    "resourceType": "Observation",
                                    "id":"obs-001",
                                    "status":"final"
                        }
                    }
                ]
            }
            """
        let data = Data(json.utf8)
        
        let bundle = try FHIRDecoder.decodeBundle(from: data)
        XCTAssertEqual(bundle.resourceType, "Bundle")
        XCTAssertEqual(bundle.id, "101")
        XCTAssertEqual(bundle.type, "collection")
        XCTAssertEqual(bundle.entry?.count, 1)
        XCTAssertEqual(bundle.entry?.first?.resource?.resourceType, "Observation")
    }
    
    func testDecodeEmptyBundleSuccessfully() throws {
        let json = """
            {
                "resourceType": "Bundle",
                "id":"101",
                "type":"collection",
                "entry":[]
            }
            """
        let data = Data(json.utf8)
        let bundle = try FHIRDecoder.decodeBundle(from: data)
        
        XCTAssertEqual(bundle.resourceType, "Bundle")
        XCTAssertEqual(bundle.entry?.count, 0)
        XCTAssertTrue(bundle.entry?.isEmpty ?? false)
    }
    
    func testDecodeResourceWithInvalidJson() throws {
        let json = """
            {
                "resourceType": "Bundle",
                "id":
            }
            """
        let data = Data(json.utf8)
        
        XCTAssertThrowsError(try FHIRDecoder.decodeResource(from: data))
    }
    
    func testDecodeResourceWithMissingStatus() throws {
        let json = """
                    {
                        "resourceType": "Bundle",
                        "id":"101"
                    }
                """
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.decodeResource(from: data))
    }
    func testDecodeResourceWithEmptyResourceType() throws {
        let json = """
            {
                "resourceType": "",
                "id":"obs-001",
                "status":"final",
            }
            """
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.decodeResource(from: data))
    }
    func testDecodeBundleWithInvalidJson() throws {
        let json = """
            {
                "resourceType": "Bundle",
                "entry":
            }
            """
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.decodeBundle(from: data))
    }
    
    func testGenericDecodeSuccessfully() throws {
        let json = """
            {
                "resourceType": "Observation",
                "id":"obs-001",
                "status":"final"
            }
            """
        let data = Data(json.utf8)
        let resource = try FHIRDecoder.decode(FHIRResource.self,from: data)
        XCTAssertEqual(resource.resourceType, "Observation")
        XCTAssertEqual(resource.id, "obs-001")
    }
    
    func testGenericDecodeWithInvalidJson() throws {
        let json = """
                {
                    "resourceType": ""
                }
            """
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.decode(FHIRResource.self,from: data))
    }
    
    func testResourceTypeSuccessfully() throws {
        let json = """
            {
                "resourceType": "DiagnosticReport",
                "id":"report-001",
                "status":"final"
            }
            """
        let data = Data(json.utf8)
        
        let resourceType = try FHIRDecoder.recourceType(from:  data)
        XCTAssertEqual(resourceType, "DiagnosticReport")
    }
    
    func testResourceTypeWithMissingField() throws {
        let json = """
            {
                "id":"report-001",
                "status":"final"
            }
            """
        
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.recourceType(from:  data))
    }
    func testResourceTypeWithInvalidJson() throws {
        let json = """
            {
                "resourceType":
            }
            """
        let data = Data(json.utf8)
        XCTAssertThrowsError(try FHIRDecoder.recourceType(from:  data))
    }
}
