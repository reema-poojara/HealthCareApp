
import XCTest
@testable import YourHealthNSDemo

@MainActor
final class FetchRecordsUseCaseTests: XCTestCase {

    // MARK: - Test 1: Successfully Fetch Records

    func testExecuteFetchesRecordsSuccessfully() async throws {

        let expectedRecords = makeSampleRecords()

        let repository = MockRecordsRepositoryForUseCase(
            records: expectedRecords
        )

        let useCase = FetchRecordsUseCase(
            repository: repository
        )

        let result = try await useCase.execute()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "report-001")
        XCTAssertEqual(result.first?.title, "Complete Blood Count")
    }

    // MARK: - Test 2: Empty Records

    func testExecuteReturnsEmptyRecords() async throws {

        let repository = MockRecordsRepositoryForUseCase(
            records: []
        )

        let useCase = FetchRecordsUseCase(
            repository: repository
        )

        let result = try await useCase.execute()

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Test 3: Repository Error

    func testExecuteThrowsRepositoryError() async {

        let repository = MockRecordsRepositoryForUseCase(
            shouldThrowError: true
        )

        let useCase = FetchRecordsUseCase(
            repository: repository
        )

        do {

            _ = try await useCase.execute()

            XCTFail("Expected repository error")

        } catch let error as APIError {

            guard case .invalidResponse = error else {
                return XCTFail("Expected invalid response error")
            }

        } catch {

            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Test 4: Repository Called Once

    func testExecuteCallsRepositoryOnce() async throws {

        let repository = MockRecordsRepositoryForUseCase(
            records: makeSampleRecords()
        )

        let useCase = FetchRecordsUseCase(
            repository: repository
        )

        _ = try await useCase.execute()

        XCTAssertEqual(
            repository.fetchRecordsCallCount,
            1
        )
    }

    // MARK: - Test 5: Repository Called On Every Execution

    func testExecuteCallsRepositoryForEveryExecution() async throws {

        let repository = MockRecordsRepositoryForUseCase(
            records: makeSampleRecords()
        )

        let useCase = FetchRecordsUseCase(
            repository: repository
        )

        _ = try await useCase.execute()
        _ = try await useCase.execute()

        XCTAssertEqual(
            repository.fetchRecordsCallCount,
            2
        )
    }

    // MARK: - Helpers

    private func makeSampleRecords() -> [PatientRecord] {

        [
            PatientRecord(
                id: "report-001",
                title: "Complete Blood Count",
                category: "Lab & Diagnostics",
                date: Date(),
                value: "",
                unit: "",
                status: "Final",
                notes: "Sample report",
                testPerformer: "ABC Diagnostic Laboratory",
                vitals: [
                    PatientVital(
                        name: "Hemoglobin",
                        value: "14.5",
                        unit: "g/dL",
                        referenceRange: "12.0–16.0 g/dL"
                    )
                ]
            )
        ]
    }
}

// MARK: - Mock Repository

private final class MockRecordsRepositoryForUseCase: RecordsRepository {

    private let records: [PatientRecord]
    private let shouldThrowError: Bool

    private(set) var fetchRecordsCallCount = 0

    init(
        records: [PatientRecord] = [],
        shouldThrowError: Bool = false
    ) {
        self.records = records
        self.shouldThrowError = shouldThrowError
    }

    func fetchRecords() async throws -> [PatientRecord] {

        fetchRecordsCallCount += 1

        if shouldThrowError {
            throw APIError.invalidResponse
        }

        return records
    }
}
