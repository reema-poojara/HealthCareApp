//
//  FHIRRecordMapper.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

/*enum FHIRRecordMapper {
    
    static func map(_ data:Data) throws ->[PatientRecord] {
        let decoder = JSONDecoder()
        let bundle = try decoder.decode(FHIRBundle.self, from: data)
        
        guard let entries = bundle.entry else {
            return []
        }
        
        var observationMap:[String:FHIRResource] = [:]
        var diagnosticReports:[FHIRResource] = []
        
        for entry in entries {
            guard let resource = entry.resource else {
                continue
            }
            if resource.resourceType == "Observation",let id = resource.id {
             observationMap[id] = resource
                if let fullUrl = entry.fullUrl{
                    let lastComponent = fullUrl.components(separatedBy: "/").last ?? id
                    observationMap[lastComponent] = resource
                }
            } else if resource.resourceType == "DiagnosticReport" {
                diagnosticReports.append(resource)
            }
        }
        var parseRecords:[PatientRecord] = []
        let dataFormatter = ISO8601DateFormatter()
        
        for report in diagnosticReports {
            
            let provider = report.performer?.first?.display ?? "Unknown"
            let reportDate = report.effectiveDateTime.flatMap { dataFormatter.date(from: $0)} ?? Date()
            let reportName = report.code?.text ?? report.code?.coding?.first?.display ?? "DIagnostic Lab Report"
            
            var summaries:[String] = []
            if let results = report.result {
                for ref in results {
                    guard let referenceString = ref.reference else { continue }
                    let refId = referenceString.components(separatedBy: "/").last ?? referenceString
                    
                    if let observation = observationMap[refId]{
                        let obsName = observation.code?.text ?? observation.code?.coding?.first?.display ?? "Unknown"
                        let value = observation.valueQuantity?.value.map{ String($0) } ?? ""
                        let unit = observation.valueQuantity?.unit ?? ""
                        
                        summaries.append("\(obsName) : \(value)\(unit)")
                    }
                }
            }
            
            let combineNotes = summaries.joined(separator: "\n")
            let value = summaries.first ?? ""
            
            let record = PatientRecord(
                id: report.id ?? "",
                title: reportName,
                category: "Lab & Diagnostics",
                date: reportDate,
                value: value,
                unit: "",
                status: report.status?.capitalized ?? "Final",
                notes: combineNotes.isEmpty ? "No Observation" : combineNotes)
            
            parseRecords.append(record)
            
            
        }
        return parseRecords
    }
}*/

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
}
