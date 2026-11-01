//
//  AppTheme.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//


import SwiftUI

struct AppTheme {
    
    struct Colors {
        static let primary = Color("PrimaryColor",bundle: .main)
        static let secondary = Color("SecondaryColor",bundle: .main)
        
        static let background = Color(.secondarySystemGroupedBackground)
        static let secondaryBackground = Color(.lightGray)
        
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
    }
    
    
    struct Fonts {
        static let largerTitle: Font = Font.system(.largeTitle,design: .default).weight(.bold)
        static let title: Font = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let title2: Font = Font.system(.title2,design: .default)
        static let body: Font = Font.system(.body,design: .default)
        static let headline: Font = Font.system(.headline,design: .default)
        static let subheadline : Font = Font.system(.subheadline,design: .default)
        static let caption : Font = Font.system(.caption,design: .default)
    }
    
}
