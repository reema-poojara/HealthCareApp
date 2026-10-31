//
//  RecordsViewModel.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-29.
//

import Foundation
import Observation

@MainActor
@Observable
final class RecordsViewModel {
    
    private(set) var records: [PatientRecord] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    
    
    private let fetchRecordsUseCase: FetchRecordsUseCase
    
    var hasRecords: Bool {
        !records.isEmpty
    }
    
    init(fetchRecordsUseCase: FetchRecordsUseCase) {
        self.fetchRecordsUseCase = fetchRecordsUseCase
    }
    
    func loadRecords() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }
        do {
            records = try await fetchRecordsUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func records(for category:String) -> [PatientRecord] {
        records.filter{
            $0.category.caseInsensitiveCompare(category) == .orderedSame
        }
    }
    
}
