//
//  RecordsHomeView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//

import SwiftUI

struct RecordsHomeView: View {
    //MARK :- iVar
    private let categories: [RecordCategory] = [
        .labAndDiagnostics
    ]
    let recordsViewModel: RecordsViewModel
    
    init(recordsViewModel: RecordsViewModel) {
            self.recordsViewModel = recordsViewModel
        }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 24){
                //Heading
                VStack(alignment: .leading, spacing: 8) {
                        Text("Health Records")
                            .font(AppTheme.Fonts.title)
                            .foregroundStyle(AppTheme.Colors.textPrimary)

                        Text("View your health information and medical records.")
                            .font(AppTheme.Fonts.body)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                // cardview
                
                VStack(spacing:16){
                    ForEach(categories) { category in
                        NavigationLink(value:category){
                            RecordCategoryCardView(category: category)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle("Records")
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationStyle()
        .navigationDestination(for: RecordCategory.self) { category in
            PatientReportsListView(category:category.title, viewModel: recordsViewModel)
        }
    }
}

#Preview {
    let container = AppContainer(mocking: true)

    NavigationStack {
        RecordsHomeView(
            recordsViewModel: container.recordsViewModel
        )
    }
}
