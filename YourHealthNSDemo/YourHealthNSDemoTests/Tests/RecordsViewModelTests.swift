//
//  RecordsViewModelTests.swift
//  YourHealthNSDemoTests
//
//  Created by reema.poojara on 2026-10-30.
//

import XCTest
@testable import YourHealthNSDemo

@MainActor
final class RecordsViewModelTests: XCTestCase {

    func testLoadREcordSuccessFully() async {
        
        let viewModel = makeViewModel()
        await viewModel.loadRecords()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasRecords)
        XCTAssertFalse(viewModel.records.isEmpty)
    }
    
    func testLoadRecordsUpdatesLoadingState() async {

        let tracker = FetchTracker()

        let viewModel = makeViewModel(
            repository: DelayedRecordsRepository(
                tracker: tracker
            )
        )

        let task = Task {
            await viewModel.loadRecords()
        }

        // Wait until repository fetching has started.
        await tracker.waitUntilStarted()

        XCTAssertTrue(viewModel.isLoading)

        await task.value

        XCTAssertFalse(viewModel.isLoading)
    }
    func testLoadRecordsHandleError() async {
        let repository = FaillingRecordsRepository()
        let viewModel = makeViewModel(repository: repository)
        
        await viewModel.loadRecords()
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.hasRecords)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Failed to fetch records")
    }
    
    func testRecordsFilterByCategory() async {
        let viewModel = makeViewModel()
        await viewModel.loadRecords()
        
        let labREcords = viewModel.records(for: "Lab & Diagnostics")
        
        XCTAssertFalse(labREcords.isEmpty)
        XCTAssertTrue(labREcords.allSatisfy{
            $0.category.caseInsensitiveCompare("Lab & Diagnostics") == .orderedSame
        })
    }
    func testRecordsFilterByCaseInsensitive() async {
        let viewModel = makeViewModel()
        await viewModel.loadRecords()
        
        let labREcords = viewModel.records(for: "lab & diagnostics")
        
        XCTAssertFalse(labREcords.isEmpty)
    }
    func testLoadRecordWithEmptyRepository() async {
        let repository = EmptyRecordsRepository()
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadRecords()
        XCTAssertTrue(viewModel.records.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.hasRecords)
        XCTAssertNil(viewModel.errorMessage)
    }
    func testREcordsReturnEmptyForUnknownCategory() async {
        let viewModel = makeViewModel()
        await viewModel.loadRecords()
        
        let labREcords = viewModel.records(for: "Appointments")
        
        XCTAssertTrue(labREcords.isEmpty)
    }
    
    private func makeViewModel(repository: (any RecordsRepository)? = nil) -> RecordsViewModel {
        
        let selectedRepository = repository ?? MockRecordsRepository()
        let useCase = FetchRecordsUseCase(repository: selectedRepository)
        return RecordsViewModel(fetchRecordsUseCase: useCase)
    }
    private struct EmptyRecordsRepository: RecordsRepository {
        func fetchRecords() async throws -> [PatientRecord] {
            []
        }
    }
    
    private struct FaillingRecordsRepository: RecordsRepository {
        func fetchRecords() async throws -> [PatientRecord] {
            throw TestError.fetchfailed
        }
    }
    
    private enum TestError:LocalizedError{
        case fetchfailed
        
        var errorDescription: String? {
            switch self {
            case .fetchfailed:
                return "Failed to fetch records"
            }
        }
    }
    private final class FetchTracker: @unchecked Sendable {

        private let lock = NSLock()
        private var continuation: CheckedContinuation<Void, Never>?
        private var hasStarted = false

        func start() {
            lock.lock()
            hasStarted = true
            let pendingContinuation = continuation
            continuation = nil
            lock.unlock()

            pendingContinuation?.resume()
        }

        func waitUntilStarted() async {
            await withCheckedContinuation { continuation in
                lock.lock()

                if hasStarted {
                    lock.unlock()
                    continuation.resume()
                } else {
                    self.continuation = continuation
                    lock.unlock()
                }
            }
        }
    }
    private struct DelayedRecordsRepository: RecordsRepository {

        let tracker: FetchTracker

        func fetchRecords() async throws -> [PatientRecord] {

            tracker.start()

            try await Task.sleep(for: .milliseconds(500))

            return [MockRecordsRepository.previewRecord]
        }
    }
}
