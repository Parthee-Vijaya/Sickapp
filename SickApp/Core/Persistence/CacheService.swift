import Foundation
import SwiftData

final class CacheService: CacheServiceProtocol, @unchecked Sendable {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @ModelActor
    actor CacheActor {
        func insertEmployees(_ employees: [Employee]) throws {
            for employee in employees {
                let cached = CachedEmployee(from: employee)
                modelContext.insert(cached)
            }
            try modelContext.save()
        }

        func fetchEmployees() throws -> [Employee] {
            let descriptor = FetchDescriptor<CachedEmployee>(
                sortBy: [SortDescriptor(\.displayName)]
            )
            return try modelContext.fetch(descriptor).map { $0.toEmployee() }
        }

        func insertAbsenceRecords(_ records: [AbsenceRecord]) throws {
            for record in records {
                let cached = CachedAbsenceRecord(from: record)
                modelContext.insert(cached)
            }
            try modelContext.save()
        }

        func fetchAbsenceRecords(managerId: String) throws -> [AbsenceRecord] {
            let descriptor = FetchDescriptor<CachedAbsenceRecord>(
                predicate: #Predicate { $0.managerId == managerId },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            return try modelContext.fetch(descriptor).map { $0.toAbsenceRecord() }
        }

        func deleteAll() throws {
            try modelContext.delete(model: CachedEmployee.self)
            try modelContext.delete(model: CachedAbsenceRecord.self)
            try modelContext.save()
        }
    }

    func cacheEmployees(_ employees: [Employee]) async throws {
        let actor = CacheActor(modelContainer: container)
        try await actor.insertEmployees(employees)
    }

    func getCachedEmployees() async throws -> [Employee] {
        let actor = CacheActor(modelContainer: container)
        return try await actor.fetchEmployees()
    }

    func cacheAbsenceRecords(_ records: [AbsenceRecord]) async throws {
        let actor = CacheActor(modelContainer: container)
        try await actor.insertAbsenceRecords(records)
    }

    func getCachedAbsenceRecords(managerId: String) async throws -> [AbsenceRecord] {
        let actor = CacheActor(modelContainer: container)
        return try await actor.fetchAbsenceRecords(managerId: managerId)
    }

    func addPendingOperation(_ operation: PendingOperation) async throws {
        // TODO: Implement with SwiftData PendingOperation model
    }

    func getPendingOperations() async throws -> [PendingOperation] {
        return []
    }

    func removePendingOperation(id: String) async throws {
        // TODO: Implement
    }

    func clearAllCache() async throws {
        let actor = CacheActor(modelContainer: container)
        try await actor.deleteAll()
    }

    func lastSyncDate() async -> Date? {
        return nil
    }
}
