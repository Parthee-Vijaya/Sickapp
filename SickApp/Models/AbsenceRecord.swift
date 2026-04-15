import Foundation

enum AbsenceStatus: String, Codable, CaseIterable {
    case active = "aktiv"
    case ended = "afsluttet"
    case cancelled = "annulleret"

    var displayName: String {
        switch self {
        case .active: "Aktiv"
        case .ended: "Afsluttet"
        case .cancelled: "Annulleret"
        }
    }
}

struct AbsenceRecord: Codable, Identifiable {
    let id: String
    let employeeId: String
    let employeeName: String
    let managerId: String
    let managerName: String
    let absenceType: AbsenceType
    let duration: AbsenceDuration
    let startDate: Date
    var endDate: Date?
    let customTypeName: String?
    let comment: String?
    let teamGroupId: String?
    var notificationSent: Bool
    var status: AbsenceStatus
    let createdAt: Date

    var daysAbsent: Int {
        let end = endDate ?? Date()
        return max(1, Calendar.current.dateComponents([.day], from: startDate.startOfDay, to: end.startOfDay).day ?? 1)
    }

    var isActive: Bool {
        status == .active
    }

    var displayType: String {
        if absenceType == .andet, let custom = customTypeName, !custom.isEmpty {
            return custom
        }
        return absenceType.displayName
    }
}
