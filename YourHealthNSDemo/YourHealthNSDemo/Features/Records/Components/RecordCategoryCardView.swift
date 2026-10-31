//
//  RecordCategoryCardView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-28.
//

import SwiftUI

struct RecordCategoryCardView: View {
    
    let category:RecordCategory
    
    var body: some View {
        
        HStack(spacing:16){
            Image(systemName: category.systemImage)
                .font(.title2)
                .foregroundStyle(AppTheme.Colors.primary)
                .frame(width: 52,height: 52)
            
//                .clipShape(
//                    RoundedRectangle(cornerRadius: 15)
//                )
                .accessibilityHidden(true)
            
            VStack(alignment:.leading,spacing: 6){
                Text(category.title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                
                Text(category.description)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppTheme.Colors.background)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens laboratory and diagnostic records")
    }
}

#Preview {
    RecordCategoryCardView(category: .labAndDiagnostics)
}
