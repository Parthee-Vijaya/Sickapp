import Foundation

protocol CacheServiceProtocol: Sendable {
    func cacheEmployees(_ employees: [Employee]) async throws
    func getCachedEmployees() async throws -> [Employee]

    func cacheAbsenceRecords(_ records: [AbsenceRecord]) async throws
    func getCachedAbsenceRecords(managerId: String) async throws -> [AbsenceRecord]

    func addPendingOperation(_ operation: PendingOperation) async throws
    func getPendingOperations() async throws -> [PendingOperation]
    func removePendingOperation(id: String) async throws

    func clearAllCache() async throws
    func lastSyncDate() async -> Date?
}

struct PendingOperation: Codable, Identifiable {
    let id: String
    let type: OperationType
    let payload: Data
    let createdAt: Date

    enum OperationType: String, Codable {
        case createAbsence
        case updateAbsence
        case cancelAbsence
    }
}
