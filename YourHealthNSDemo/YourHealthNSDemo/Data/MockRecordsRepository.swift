//
//  MockRecordsRepository.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

struct MockRecordsRepository: RecordsRepository {
    
    func fetchRecords() async throws -> [PatientRecord] {
        Self.sampleRecords
    }
    
    private static let sampleRecords: [PatientRecord] = [
        PatientRecord(
            id:"report1",
            title: "Complete Blood Count",
            category: "Lab & Diagnostics",
            date: makeDate(daysAgo:1),
            value: "",
            unit: "",
            status: "Final",
            notes: "Smaple Reports",
            testPerformer: "abc Diagnostic Laboratory",
        vitals: [
            PatientVital(
                name: "Red Cell Count",
                value: "5.9",
                unit: "×10¹²/L",
                referenceRange: "4.2–5.8 ×10¹²/L"
            ),
            PatientVital(
                name: "Hemoglobin",
                value: "14.5",
                unit: "g/dL",
                referenceRange: "12.0–16.0 g/dL"
            ),
            PatientVital(
                name: "White Blood Cell Count",
                value: "7.2",
                unit: "×10⁹/L",
                referenceRange: "4.0–11.0 ×10⁹/L"
            )
        ])
    ]
    
    private static func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day,value: -daysAgo, to: .now) ?? .now
    }
    static var previewRecord: PatientRecord {
        sampleRecords[0]
    }
        
}
