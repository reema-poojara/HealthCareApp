//
//  FetchRecordsUseCase.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-29.
//

import Foundation

struct FetchRecordsUseCase {
    
    private let repository: any RecordsRepository
    
    init(repository: any RecordsRepository) {
        self.repository = repository
    }
    
    func execute() async throws -> [PatientRecord] {
        try await repository.fetchRecords()
    }
}
