import Foundation

protocol APIClientProtocol: Sendable {
    // Manager
    func getMe() async throws -> Manager
    func getDirectReports() async throws -> [Employee]
    func getEmployeePhoto(employeeId: String) async throws -> Data

    // Groups
    func getMyGroups() async throws -> [TeamGroup]
    func getGroupMembers(groupId: String) async throws -> [Employee]

    // Absences
    func createAbsence(_ record: AbsenceRecord) async throws -> AbsenceRecord
    func getAbsences(managerId: String, status: AbsenceStatus?, type: AbsenceType?) async throws -> [AbsenceRecord]
    func getAbsence(id: String) async throws -> AbsenceRecord
    func updateAbsence(id: String, endDate: Date?, status: AbsenceStatus?) async throws -> AbsenceRecord
    func cancelAbsence(id: String) async throws
    func extendAbsence(id: String, newEndDate: Date) async throws -> AbsenceRecord
    func getAbsenceStats(managerId: String, period: StatsPeriod) async throws -> AbsenceStats

    // Notifications
    func sendNotification(absenceId: String, groupId: String) async throws
}

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week = "uge"
    case month = "måned"
    case quarter = "kvartal"
    case year = "år"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week: "Uge"
        case .month: "Måned"
        case .quarter: "Kvartal"
        case .year: "År"
        }
    }
}

struct AbsenceStats: Codable {
    let totalDays: Int
    let totalRecords: Int
    let byType: [AbsenceTypeCount]
    let monthlyTrend: [MonthlyCount]
    let previousPeriodDays: Int

    var trendPercentage: Double {
        guard previousPeriodDays > 0 else { return 0 }
        return Double(totalDays - previousPeriodDays) / Double(previousPeriodDays) * 100
    }

    struct AbsenceTypeCount: Codable, Identifiable {
        let type: AbsenceType
        let count: Int
        let days: Int
        var id: String { type.rawValue }
    }

    struct MonthlyCount: Codable, Identifiable {
        let month: String
        let count: Int
        let days: Int
        var id: String { month }
    }
}
