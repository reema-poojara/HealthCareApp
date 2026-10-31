//
//  AppContainer.swift
//  YourHealthNSDemo
//
//  Created by reema.poojara on 2026-10-27.
//

import Foundation

@MainActor
final class AppContainer {
    static let shared = AppContainer()
    
    let recordsRepository: RecordsRepository
    
    lazy var fetchRecordsUseCase = FetchRecordsUseCase(repository: recordsRepository)
    lazy var recordsViewModel = RecordsViewModel(fetchRecordsUseCase: fetchRecordsUseCase)
    
    private init() {
        self.recordsRepository = RemoteRecordsRepository()
    }
    
    init (mocking useMockData:Bool) {
        self.recordsRepository = MockRecordsRepository()
    }
}
