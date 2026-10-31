//
//  FHIRModels.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

struct FHIRResource:Decodable {
    let resourceType:String
    let id:String?
    let status:String
    let code:FHIRCodableConcept?
    let subject:FHIRReference?
    let performer:[FHIRReference]?
    let issued:String?
    let effectiveDateTime:String?
    let effectivePeriod:FHIRPeriod?
    let result:[FHIRReference]?
    let valueQuantity:FHIRQuantity?
    let referenceRange:[FHIRObservationReferenceRange]?
    let entry:[FHIRBundleEntry]?
    enum CodingKeys: String, CodingKey {
        case resourceType
        case id, status, code, subject, performer, issued, effectiveDateTime, effectivePeriod, result, valueQuantity, referenceRange, entry
    }
}
    
    struct FHIRBundle: Decodable {
        let resourceType: String
        let id: String?
        let type: String?
        let entry: [FHIRBundleEntry]?
    }
    
    struct FHIRBundleEntry: Decodable {
        let fullUrl: String?
        let resource: FHIRResource?
    }
    struct FHIRCodableConcept:Decodable {
        let coding:[FHIRCoding]?
        let text:String?
        
        var displayName:String?{
            if let text, !text.isEmpty{
                return text
            }
            
            return coding?.first(where:{
                guard let display = $0.display else { return false }
                
                return !display.isEmpty
            })?.display
        }
    }
    struct FHIRCoding:Decodable {
        let system:String?
        let code:String?
        let display:String?
    }
    struct FHIRReference:Decodable {
        let reference:String?
        let type:String?
        let display:String?
        
        var referenceId:String?{
            guard let reference, !reference.isEmpty else { return nil }
            
            return reference.split(separator: "/").last.map(String.init)
        }
    }
    struct FHIRQuantity:Decodable {
        let value:Double?
        let comparator:String?
        let unit:String?
        let system:String?
        let code:String?
        
        var displayValue:String?{
            guard let value else { return nil }
            
            let formattedValue = String(value)
            
            guard let unit, !unit.isEmpty else { return formattedValue }
            
            return "\(formattedValue) \(unit)"
        }
    }
    struct FHIRObservationReferenceRange:Decodable{
        let low:FHIRQuantity?
        let high:FHIRQuantity?
        let text:String?
        
        var displayRange:String?{
            if let text, !text.isEmpty{
                return text
            }
            
            let lower = low?.displayValue
            let upper = high?.displayValue
            
            switch (lower,upper){
            case let (lower?,upper?):
                return "\(lower) - \(upper)"
            case let (lower?,nil):
                return "≥ \(lower)"
            case let (nil,upper?):
                return "≤  \(upper)"
            default:
                return nil
            }
        }
    }
    struct FHIRPeriod:Decodable {
        let start:String?
        let end:String?
    }
