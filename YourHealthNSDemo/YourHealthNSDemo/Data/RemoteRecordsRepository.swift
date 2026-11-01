//
//  RemoteRecordsRepository.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation
import ModelsR4

struct RemoteRecordsRepository : RecordsRepository{
    
    private let apiClient: APIClient
    private let endPoint = URL(string: "https://build.fhir.org/diagnosticreport-example.json")
    
    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchRecords() async throws ->[PatientRecord] {
        guard let endPoint else {
            throw APIError.invalidURL
        }
        let data : Data = try await apiClient.getRawData(from: endPoint)
        let resourceType = try FHIRDecoder.recourceType(from: data)
        
        switch resourceType {
            
            case "Bundle":
                let bundle = try FHIRDecoder.decodeFHIR(from: data)
                return FHIRRecordMapper.mapFHIRBundle(bundle)
            case "DiagnosticReport", "Observation":
                let resources = try decodeResource(from: data)
                return FHIRRecordMapper.map(resources: resources)
            default:
                throw APIError.missingResource("Expected FHIR Bundle or resource")
        }
    }
//    func fetchRecords()async throws ->[PatientRecord] {
//        let data : Data = try await apiClient.getRawData(from: endPoint!)
//        let resources = try decodeResource(from: data)
//        
//        return FHIRRecordMapper.map(resources: resources)
//    }
    
    private func decodeResource(from data: Data) throws -> [FHIRResource] {
        let resourceType = try FHIRDecoder.recourceType(from:data)
        
        switch resourceType {
            
        case "Bundle":
            let bundle = try FHIRDecoder.decodeBundle(from: data)
            return bundle.entry?.compactMap(\.resource) ?? []
        case "DiagnosticReport", "Observation":
            return [try FHIRDecoder.decodeResource(from: data)]
        default:
            if let resources = try? JSONDecoder().decode([FHIRResource].self, from: data) {
                return resources
            }
            throw APIError.missingResource("Expected FHIR resource")
        }
        
    }
}
