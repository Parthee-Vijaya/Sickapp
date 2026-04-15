import Foundation

final class MockCacheService: CacheServiceProtocol, @unchecked Sendable {
    private var employees: [Employee] = []
    private var records: [AbsenceRecord] = []
    private var operations: [PendingOperation] = []

    func cacheEmployees(_ employees: [Employee]) async throws {
        self.employees = employees
    }

    func getCachedEmployees() async throws -> [Employee] {
        employees
    }

    func cacheAbsenceRecords(_ records: [AbsenceRecord]) async throws {
        self.records = records
    }

    func getCachedAbsenceRecords(managerId: String) async throws -> [AbsenceRecord] {
        records.filter { $0.managerId == managerId }
    }

    func addPendingOperation(_ operation: PendingOperation) async throws {
        operations.append(operation)
    }

    func getPendingOperations() async throws -> [PendingOperation] {
        operations
    }

    func removePendingOperation(id: String) async throws {
        operations.removeAll { $0.id == id }
    }

    func clearAllCache() async throws {
        employees.removeAll()
        records.removeAll()
        operations.removeAll()
    }

    func lastSyncDate() async -> Date? {
        Date()
    }
}
