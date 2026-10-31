//
//  FHIRRecordMapperTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-30.
//

import XCTest
@testable import YourHealthNSDemo

final class FHIRRecordMapperTests: XCTestCase {

    func testMapDiagnosticReportSuccess(){
        
        let report = makeResource(
                    resourceType: "DiagnosticReport",
                    id: "report-001",
                    status: "final",
                    code: FHIRCodableConcept(
                        coding: nil,
                        text: "Complete Blood Count"
                    )
                )
        let result = FHIRRecordMapper.map(resources: [report])
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "report-001")
        XCTAssertEqual(result.first?.title, "Complete Blood Count")
        XCTAssertEqual(result.first?.category, "Lab & Diagnostics")
        XCTAssertEqual(result.first?.status, "final")
    }

    func testMapObservationSuccess(){
        let report = makeResource(
                    resourceType: "DiagnosticReport",
                    id: "report-002",
                    status: "final",
                    code: FHIRCodableConcept(
                        coding: nil,
                        text: "CBC"
                    ),
                    result: [
                        FHIRReference(
                            reference: "Observation/obs-001",
                            type: nil,
                            display: nil
                        )
                    ]
                )
        let observation = makeResource(
                    resourceType: "Observation",
                    id: "obs-001",
                    status: "final",
                    code: FHIRCodableConcept(
                        coding: nil,
                        text: "Hemoglobin"
                    ),
                    valueQuantity: FHIRQuantity(
                        value: 14.5,
                        comparator: nil,
                        unit: "g/dL",
                        system: nil,
                        code: nil
                    ),
                    referenceRange: [
                        FHIRObservationReferenceRange(
                            low: FHIRQuantity(
                                value: 12.0,
                                comparator: nil,
                                unit: "g/dL",
                                system: nil,
                                code: nil
                            ),
                            high: FHIRQuantity(
                                value: 16.0,
                                comparator: nil,
                                unit: "g/dL",
                                system: nil,
                                code: nil
                            ),
                            text: nil
                        )
                    ]
                )
        let result = FHIRRecordMapper.map(resources: [report,observation])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.vitals.count, 1)
        
        let vitals = result.first?.vitals.first
        XCTAssertEqual(vitals?.id, "obs-001")
        XCTAssertEqual(vitals?.name, "Hemoglobin")
        XCTAssertEqual(vitals?.value, "14.5")
        XCTAssertEqual(vitals?.unit, "g/dL")
        XCTAssertEqual(vitals?.referenceRange, "12.0 g/dL - 16.0 g/dL")
    }
    
    func testMapReportwithMissingObservationRefrence() {
        let report = makeResource(
                    resourceType: "DiagnosticReport",
                    id: "report-003",
                    status: "final",
                    result: [
                        FHIRReference(
                            reference: "Observation/unknown",
                            type: nil,
                            display: nil
                        )
                    ]
                )
        let result = FHIRRecordMapper.map(resources: [report])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.vitals.count, 0)
    }
    
    func testMapREportWithoutID() {
        
        let report = makeResource(
                    resourceType: "DiagnosticReport",
                    id: nil,
                    status: "final"
                )
        
        let result = FHIRRecordMapper.map(resources: [report])
        XCTAssertTrue(result.isEmpty)
    }
    
    func testMapReportWithMissingOptionalFields() {
        let report = makeResource(
                    resourceType: "DiagnosticReport",
                    id: "report-004",
                    status: "final"
                )
        let result = FHIRRecordMapper.map(resources: [report])
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.vitals.count, 0)
        XCTAssertEqual(result.first?.title, "Diagnostic report")
        XCTAssertEqual(result.first?.testPerformer, "")
    }
    
    func testMapWithEmptyResources() {
        let result = FHIRRecordMapper.map(resources: [])
        XCTAssertTrue(result.isEmpty)
    }
    
    func testMapMultipleDiagnosticReports() {
        let report1 = makeResource(
            resourceType: "DiagnosticReport",
            id: "report-001",
            status: "final"
        )
        let report2 = makeResource(
            resourceType: "DiagnosticReport",
            id: "report-002",
            status: "preliminary"
            )
            
            let result = FHIRRecordMapper.map(resources: [report1,report2])
            
            XCTAssertEqual(result.count, 2)
            XCTAssertEqual(result[0].id, "report-001")
            XCTAssertEqual(result[1].id, "report-002")
            
    }
    
    private func makeResource(
        resourceType: String,
        id: String?,
        status: String,
        code: FHIRCodableConcept? = nil,
        performer: [FHIRReference]? = nil,
        issued:String? = nil,
        effectiveDateTime: String? = nil,
        effectivePeriod: FHIRPeriod? = nil,
        result:[FHIRReference]? = nil,
        valueQuantity: FHIRQuantity? = nil,
        referenceRange:[FHIRObservationReferenceRange]? = nil
        
    ) -> FHIRResource
    {
        FHIRResource(resourceType: resourceType,
                     id: id,
                     status: status,
                     code: code,
                     subject: nil,
                     performer: performer,
                     issued: issued,
                     effectiveDateTime: effectiveDateTime,
                     effectivePeriod: effectivePeriod,
                     result: result,
                     valueQuantity: valueQuantity,
                     referenceRange: referenceRange,
                     entry: nil)
    }
}

