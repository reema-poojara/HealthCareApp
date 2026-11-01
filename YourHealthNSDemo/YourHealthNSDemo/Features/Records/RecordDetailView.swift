//
//  RecordDetailView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-29.
//

import SwiftUI

struct RecordDetailView: View {
    
    let record:PatientRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20){
                reportInformation
                
                Divider()
                
                observationResult
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(record.title)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationStyle()
    }
    
    private var reportInformation: some View {
        VStack(alignment: .leading, spacing: 12){
            informationSection(title:"Record Name",value:record.title)
            informationSection(title:"Test Performer",value:record.testPerformer.isEmpty
                               ? "Not available"
                               : record.testPerformer)
            informationSection(title:"Result Date and Time",value:record.date.formatted(
                Date.FormatStyle()
                    .month(.wide)
                    .day()
                    .year()
                    .hour()
                    .minute()
                    .second()
                )
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Report Information")
    }
    
    private var observationResult: some View {
        VStack(alignment: .leading, spacing: 12){
//            Text("Result Observations")
//                .font(AppTheme.Fonts.headline)
            
            ForEach(Array(record.vitals.enumerated()),id: \.element.id){
                 index,vital in
                
                observationCard(vital:vital)
            }
        }
        .accessibilityElement(children: .contain)
    }
    
    private func observationCard(vital:PatientVital) -> some View {
        let referenceRange = vital.referenceRange?.isEmpty == false
                    ? vital.referenceRange!
                    : "Not available"
        
        return VStack(alignment: .leading, spacing: 12){
            // observation heading
            Text(vital.name)
                .font(AppTheme.Fonts.headline)
                .accessibilityAddTraits(.isHeader)
            
            // result row
            HStack{
                Text("Result")
                    .font(AppTheme.Fonts.headline)
                    
                
                Text(vital.displayValue)
                    .font(AppTheme.Fonts.caption)
            }
            
            HStack{
                Text("Normal Range")
                    .font(AppTheme.Fonts.headline)
                
                Text(referenceRange)
                .font(AppTheme.Fonts.caption)
                
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(vital.name). Result: \(vital.displayValue). Normal Range: \(referenceRange)")
    }
    
    private func informationSection(title:String,value:String) -> some View {
            VStack(alignment: .leading, spacing: 6) {

                Text(title)
                    .font(AppTheme.Fonts.headline)
                    
                Text(value)
                    .font(AppTheme.Fonts.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
    }
    
}

#Preview {
    NavigationStack {
            RecordDetailView(
                record: MockRecordsRepository.previewRecord
            )
        }
}
