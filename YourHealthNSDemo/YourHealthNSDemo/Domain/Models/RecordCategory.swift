//
//  RecordCategory.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import Foundation

struct RecordCategory :Identifiable,Hashable {
    
    let id : String
    let title : String
    let description : String
    let systemImage: String
    
    
    static let labAndDiagnostics = RecordCategory(
        id: "labAndDiagnostics",
        title: "Lab & Diagnostics",
        description: "Results for blood, urin, and general lab",
        systemImage: "flask"
    )
}
