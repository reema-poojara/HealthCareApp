//
//  PatientReportsListView.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-29.
//

import SwiftUI

struct PatientReportsListView: View {
    
    let category:String
    
    @State private var viewModel:RecordsViewModel
    @State private var selectedRecords: PatientRecord?
    
    init(category: String, viewModel: RecordsViewModel) {
        self.category = category
        self.viewModel = viewModel
    }
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.records.isEmpty {
                loadingView
            } else if let errorMessage = viewModel.errorMessage,viewModel.records.isEmpty {
                errorView(message:errorMessage)
            }else if filteredRecords.isEmpty {
                emptyView
            } else {
                recordList
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(category)
        .navigationBarTitleDisplayMode(.inline)
        .appNavigationStyle()
        .navigationDestination(item: $selectedRecords){ record in
            RecordDetailView(record: record)
        }
        .task {
            if viewModel.records.isEmpty {
                await viewModel.loadRecords()
            }
        }
    }
    
    private var filteredRecords: [PatientRecord] {
        viewModel.records(for: category)
    }
    
    private var recordList: some View {
        List(filteredRecords) { record in
            Button{
                selectedRecords = record
            } label: {
                recordRow(record)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(record.title), \(record.status), \(record.date.formatted(date: .complete, time: .shortened))")
            .accessibilityHint("Double tap to open the report details.")
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
        
        private func recordRow(_ record: PatientRecord) -> some View {
            HStack(spacing: 12){
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .frame(width: 44,height: 44)
                    .background(AppTheme.Colors.secondary,in: RoundedRectangle(cornerRadius: 12))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5){
                    Text(record.title)
                        .font(AppTheme.Fonts.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                    Text(record.date.formatted(date: .abbreviated,time: .omitted))
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    Text(record.status.capitalized)
                        .font(AppTheme.Fonts.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical,6)
            .contentShape(Rectangle())
        }
        
        private var loadingView: some View {
            VStack(spacing: 12){
                ProgressView()
                    .tint(AppTheme.Colors.primary)
                Text("Loading Patient records...")
                    .font(AppTheme.Fonts.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading patient records")
            .accessibilityAddTraits(.updatesFrequently)
    }
    private var emptyView: some View {
        ContentUnavailableView("No Patient Records", systemImage: "doc.text",description: Text("No Patient records have been created yet."))
            .foregroundStyle(AppTheme.Colors.textSecondary)
    }
        private func errorView(message: String) -> some View {
            ContentUnavailableView{
                Label("Unable to load records", systemImage: "exclamationmark.bubble.fill")
            } description :{
                    Text(message)
            }actions: {
                Button("Try again"){
                    Task {
                        await viewModel.loadRecords()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.Colors.primary)
                .accessibilityHint("Try to reload the list of patient records")
            }
    }
    
}

#Preview {
    let container = AppContainer(mocking: true)
        NavigationStack {
            PatientReportsListView(
                category: "Lab & Diagnostics",
                viewModel: container.recordsViewModel
            )
        }
}
