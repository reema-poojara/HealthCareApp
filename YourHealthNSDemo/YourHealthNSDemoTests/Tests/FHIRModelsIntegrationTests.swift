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

            // Replace with your actual FHIR Bundle JSON fixture
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

            print("Diagnostic reports:", reports.count)

            XCTAssertNotNil(bundle.entry)
        }

}
