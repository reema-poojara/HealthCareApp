//
//  FHIRModelsIntegrationTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-11-01.
//

import XCTest
import ModelsR4

@testable import YourHealthNSDemo

final class FHIRModelsIntegrationTests: XCTestCase {

    func testFHIRModelsBundleDecoding() throws {
        
        let json = """
        {
            "resourceType": "Bundle",
            "id": "101",
            "type": "collection",
            "entry": [
                {
                    "fullUrl": "https://example.com/base/DiagnosticReport/101",
                    "resource": {
                        "resourceType": "DiagnosticReport",
                        "id": "obs-001",
                        "status": "final",
                        "code": {
                            "coding": [
                                {
                                    "system": "http://loinc.org",
                                    "code": "58410-2",
                                    "display": "Complete blood count"
                                }
                            ],
                            "text": "Complete Blood Count"
                        }
                    }
                }
            ]
        }
        """

        let data = Data(json.utf8)

        let bundle = try FHIRDecoder.decodeFHIR(from: data)

        let reports = bundle.entry?.compactMap {
            $0.resource?.get(
                if: ModelsR4.DiagnosticReport.self
            )
        } ?? []

        //Verify Bundle and DiagnosticReport
        XCTAssertEqual(bundle.entry?.count,1)
        XCTAssertEqual(reports.count, 1)

        let report = try XCTUnwrap(reports.first)

        XCTAssertEqual(report.id?.value?.string, "obs-001")
        XCTAssertEqual(report.code.text?.value?.string,"Complete Blood Count")
    }
    
    func testFHIRObservationMapping() throws {

        let json = """
        {
            "resourceType": "Bundle",
            "type": "collection",
            "entry": [
                {
                    "fullUrl": "https://example.com/DiagnosticReport/report-001",
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
                },
                {
                    "fullUrl": "https://example.com/Observation/obs-001",
                    "resource": {
                        "resourceType": "Observation",
                        "id": "obs-001",
                        "status": "final",
                        "code": {
                            "text": "Lymphocytes"
                        },
                        "valueQuantity": {
                            "value": 0.9,
                            "unit": "x10*9/L",
                            "system": "http://unitsofmeasure.org",
                            "code": "10*9/L"
                        },
                        "referenceRange": [
                            {
                                "low": {
                                    "value": 1.1,
                                    "unit": "x10*9/L"
                                },
                                "high": {
                                    "value": 4.0,
                                    "unit": "x10*9/L"
                                }
                            }
                        ]
                    }
                }
            ]
        }
        """

        let data = Data(json.utf8)

        let bundle = try FHIRDecoder.decodeFHIR(from: data)

        let records = FHIRRecordMapper.mapFHIRBundle(bundle)

        XCTAssertEqual(records.count, 1)

        let record = try XCTUnwrap(records.first)

        XCTAssertEqual(record.id, "report-001")
        XCTAssertEqual(record.title, "Complete Blood Count")

        XCTAssertEqual(record.vitals.count, 1)

        let vital = try XCTUnwrap(record.vitals.first)

        XCTAssertEqual(vital.id, "obs-001")
        XCTAssertEqual(vital.name, "Lymphocytes")
        XCTAssertEqual(vital.value, "0.9")
        XCTAssertEqual(vital.unit, "x10*9/L")
        XCTAssertEqual(
            vital.referenceRange,
            "1.1 x10*9/L - 4 x10*9/L"
        )
    }
    
    func testFHIRBundleWithoutDiagnosticReportsReturnsEmptyRecords() throws {

        let json = """
        {
            "resourceType": "Bundle",
            "type": "collection",
            "entry": []
        }
        """

        let data = Data(json.utf8)

        let bundle = try FHIRDecoder.decodeFHIR(from: data)

        let records = FHIRRecordMapper.mapFHIRBundle(bundle)

        XCTAssertTrue(records.isEmpty)
    }

    func testFHIRReportWithoutIDIsSkipped() throws {

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

        let data = Data(json.utf8)

        let bundle = try FHIRDecoder.decodeFHIR(from: data)

        let records = FHIRRecordMapper.mapFHIRBundle(bundle)

        XCTAssertTrue(records.isEmpty)
    }
}
