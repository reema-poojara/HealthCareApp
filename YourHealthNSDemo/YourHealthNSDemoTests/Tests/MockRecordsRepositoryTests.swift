//
//  MockRecordsRepositoryTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-30.
//

import XCTest
@testable import YourHealthNSDemo

@MainActor
final class MockRecordsRepositoryTests: XCTestCase {
    // MARK: - Test 1: Fetch Sample Records

        func testFetchRecordsReturnsSampleRecords() async throws {

            let repository = MockRecordsRepository()

            let records = try await repository.fetchRecords()

            XCTAssertFalse(records.isEmpty)
            XCTAssertEqual(records.count, 1)
        }
    // MARK: - Test 2: Validate CBC Report

        func testFetchRecordsReturnsCorrectCBCReport() async throws {

            let repository = MockRecordsRepository()

            let records = try await repository.fetchRecords()

            let record = try XCTUnwrap(records.first)

            XCTAssertEqual(record.id, "report1")
            XCTAssertEqual(record.title, "Complete Blood Count")
            XCTAssertEqual(record.category, "Lab & Diagnostics")
            XCTAssertEqual(record.status, "Final")
            XCTAssertEqual(record.testPerformer, "abc Diagnostic Laboratory")
        }
    // MARK: - Test 3: Validate Patient Vitals

        func testFetchRecordsReturnsPatientVitals() async throws {

            let repository = MockRecordsRepository()

            let records = try await repository.fetchRecords()

            let record = try XCTUnwrap(records.first)

            XCTAssertEqual(record.vitals.count, 3)

            XCTAssertEqual(record.vitals[0].name, "Red Cell Count")
            XCTAssertEqual(record.vitals[1].name, "Hemoglobin")
            XCTAssertEqual(record.vitals[2].name, "White Blood Cell Count")
        }
    // MARK: - Test 4: Validate Vital Values

        func testPatientVitalValuesAreCorrect() async throws {

            let repository = MockRecordsRepository()

            let records = try await repository.fetchRecords()

            let record = try XCTUnwrap(records.first)

            let hemoglobin = try XCTUnwrap(
                record.vitals.first {
                    $0.name == "Hemoglobin"
                }
            )

            XCTAssertEqual(hemoglobin.value, "14.5")
            XCTAssertEqual(hemoglobin.unit, "g/dL")
            XCTAssertEqual(hemoglobin.referenceRange,"12.0–16.0 g/dL")
        }
    // MARK: - Test 5: Validate Preview Record

        func testPreviewRecordReturnsCorrectRecord() {

            let record = MockRecordsRepository.previewRecord

            XCTAssertEqual(record.id, "report1")
            XCTAssertEqual(record.title, "Complete Blood Count")
            XCTAssertEqual(record.vitals.count, 3)
        }

        // MARK: - Test 6: Validate Sample Notes

        func testSampleRecordContainsNotes() async throws {

            let repository = MockRecordsRepository()

            let records = try await repository.fetchRecords()

            let record = try XCTUnwrap(records.first)

            XCTAssertEqual(record.notes, "Smaple Reports")
        }
   
}
