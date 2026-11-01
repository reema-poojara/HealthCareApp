//
//  FHIRRecordMapper.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation
import ModelsR4

enum FHIRRecordMapper {
    
    static func map(resources:[FHIRResource]) -> [PatientRecord] {
        let observations = Dictionary(resources
            .filter { $0.resourceType == "Observation" }
            .compactMap{ observations in observations.id.map{($0, observations)}},
                                      uniquingKeysWith: { first, _ in first}
        )
        return resources
            .filter{ $0.resourceType == "DiagnosticReport"}
            .compactMap { report in
                mapReport(report,observations: observations)
                
            }
    }
    static func mapFHIRBundle(_ bundle: ModelsR4.Bundle) -> [PatientRecord] {

            let observations: [ModelsR4.Observation] =
                bundle.entry?.compactMap {
                    $0.resource?.get(if: ModelsR4.Observation.self)
                } ?? []

            let reports: [ModelsR4.DiagnosticReport] =
                bundle.entry?.compactMap {
                    $0.resource?.get(if: ModelsR4.DiagnosticReport.self)
                } ?? []

            return reports.compactMap { report in
                mapFHIRReport(report, observations: observations)
            }
    }
    
    private static func mapFHIRReport(_ report: ModelsR4.DiagnosticReport,observations: [ModelsR4.Observation]) -> PatientRecord? {

        guard let reportID = report.id?.value?.string else {
            return nil
        }

        let reportName: String =
            report.code.text?.value?.string ??
            report.code.coding?
                .compactMap { $0.display?.value?.string }
                .first ??
            "Diagnostic report"

        let reportVitals: [PatientVital] =
            (report.result ?? []).compactMap { reference in

                guard let referenceID = reference.reference?.value?.string.split(separator: "/").last.map(String.init),let observation = observations.first(where: {
                        $0.id?.value?.string == referenceID
                }) else {
                    return nil
                }
                return mapFHIRObservation(observation)
            }

        let performerNames: [String] = (report.performer ?? [])
            .compactMap { $0.display?.value?.string }

        let performerText = performerNames.joined(separator: ", ")

        // Extract actual report date
        let reportDate = extractReportDate(report)
        let date = parseFHIRDate(reportDate)

        return PatientRecord(
            id: reportID,
            title: reportName,
            category: "Lab & Diagnostics",
            date: date ?? .now,
            value: "",
            unit: "",
            status: report.status.value?.rawValue ?? "unknown",
            notes: "",
            testPerformer: performerText,
            vitals: reportVitals
        )
    }
    
    private static func mapFHIRObservation(_ observation: ModelsR4.Observation) -> PatientVital {

        // MARK: - Observation Name

        let name: String =
            observation.code.text?.value?.string ??
            observation.code.coding?
                .compactMap { $0.display?.value?.string }
                .first ??
            ""

        // MARK: - Extract Quantity

        var quantity: ModelsR4.Quantity?

        if let observationValue = observation.value {
            switch observationValue {
            case .quantity(let value):
                quantity = value
            default:
                quantity = nil
            }
        }

        // MARK: - Result Value

        let numericValue: String

        if let decimal = quantity?.value?.value {
            numericValue = NSDecimalNumber(decimal: decimal.decimal).stringValue
        } else {
            numericValue = ""
        }

        let unit = quantity?.unit?.value?.string ?? quantity?.code?.value?.string ?? ""

        // MARK: - Reference Range

        let ranges = (observation.referenceRange ?? [])
            .compactMap { range -> String? in

                let low = range.low
                let high = range.high

                let lower: String? = low?.value?.value.map {
                    let number = NSDecimalNumber(decimal: $0.decimal).stringValue

                    let unit = low?.unit?.value?.string ?? ""

                    return unit.isEmpty ? number : "\(number) \(unit)"
                }

                let upper: String? = high?.value?.value.map {
                    let number = NSDecimalNumber(decimal: $0.decimal).stringValue

                    let unit = high?.unit?.value?.string ?? ""

                    return unit.isEmpty ? number : "\(number) \(unit)"
                }

                let rangeText = range.text?.value?.string

                if let rangeText, !rangeText.isEmpty {
                    return rangeText
                }

                switch (lower, upper) {

                case let (lower?, upper?):
                    return "\(lower) - \(upper)"

                case let (lower?, nil):
                    return ">= \(lower)"

                case let (nil, upper?):
                    return "<= \(upper)"

                default:
                    return nil
                }
            }
            .joined(separator: ", ")

        // MARK: - Return Patient Vital

        return PatientVital(
            id: observation.id?.value?.string ?? UUID().uuidString,
            name: name,
            value: numericValue,
            unit: unit,
            referenceRange: ranges
        )
    }


    private static func mapReport(_ report: FHIRResource,observations: [String: FHIRResource]) -> PatientRecord? {
        
        guard let reportID = report.id else { return nil }
        
        let reportName = report.code?.displayName ?? "Diagnostic report"
        
        let vitals:[PatientVital] = (report.result ?? [])
            .compactMap{ reference in
                
            guard let observationId = reference.referenceId, let observation = observations[observationId] else { return nil }
                 return mapObservation(observation)
        }
        
        let performerNames = (report.performer ?? [])
            .compactMap{$0.display}
        
        let performerText = performerNames.isEmpty ? "" : performerNames.joined(separator: ",")
        
        let date = parseDate(report.effectiveDateTime ?? report.effectivePeriod?.start ?? report.issued) ?? .now
        
        return PatientRecord(
            id: reportID,
            title: reportName,
            category: "Lab & Diagnostics",
            date: date,
            value: "",
            unit: "",
            status: report.status,
            notes: "",
            testPerformer: performerText,
            vitals: vitals)
    }
    private static func mapObservation(_ observation:FHIRResource)->PatientVital {
        let quantity = observation.valueQuantity
        
        let value = quantity?.value.map{ String($0)} ?? ""
        
        let unit = quantity?.unit ?? ""
        
        let referenceRange = (observation.referenceRange ?? [])
            .compactMap(\.displayRange)
            .joined(separator: ", ")
        
        return PatientVital(id:observation.id ?? UUID().uuidString,name: observation.code?.displayName ?? "",value: value,unit: unit,referenceRange: referenceRange)
        
    }
    private static func parseDate(_ value:String?)->Date? {
        
        guard let value else { return nil }
        
        let formatter = ISO8601DateFormatter()
        
        if let date = formatter.date(from: value){
            return date
        }
        
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter.date(from: value)
    }
    private static func extractReportDate(_ report: ModelsR4.DiagnosticReport) -> String? {

        if let effective = report.effective {
            switch effective {

            case .dateTime(let dateTime):
                return dateTime.value?.description

            case .period(let period):
                return period.start?.value?.description
            }
        }

        return report.issued?.value?.description
    }
    private static func parseFHIRDate(_ value: String?) -> Date? {

        guard let value else { return nil }

        let formatter = ISO8601DateFormatter()

        if let date = formatter.date(from: value) {
            return date
        }

        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        if let date = formatter.date(from: value) {
            return date
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.date(from: value)
    }
}
