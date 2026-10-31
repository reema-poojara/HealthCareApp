//
//  PatientRecord.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

struct PatientRecord: Codable,Identifiable,Hashable{
    
    let id:String
    let title:String
    let category:String
    let date:Date
    let value:String
    let unit:String
    let status:String
    let notes:String
    let testPerformer: String
    let vitals:[PatientVital]
    
    init(id:String = UUID().uuidString,
         title:String,
         category:String,
         date:Date,
         value:String,
         unit:String,
         status:String,
         notes:String,
         testPerformer: String = "",
         vitals:[PatientVital] = []
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.date = date
        self.value = value
        self.unit = unit
        self.status = status
        self.notes = notes
        self.testPerformer = testPerformer
        self.vitals = vitals
    }
}
struct PatientVital: Codable,Identifiable,Hashable {
    let id:String
    let name:String
    let value:String?
    let unit:String?
    let referenceRange:String?
    
    
    var displayValue: String {
        guard let value else { return "N/A" }
        
        guard let unit else { return value }
        return "\(value) \(unit)"
    }
    
    init(id:String = UUID().uuidString,
         name:String,
         value:String = "",
         unit:String = "",
         referenceRange:String = "")
    {
        self.id = id
        self.name = name
        self.value = value
        self.unit = unit
        self.referenceRange = referenceRange
    }
}
