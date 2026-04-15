import Foundation
import SwiftData

enum SwiftDataContainer {
    static func create() throws -> ModelContainer {
        let schema = Schema([
            CachedEmployee.self,
            CachedAbsenceRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    static func createInMemory() throws -> ModelContainer {
        let schema = Schema([
            CachedEmployee.self,
            CachedAbsenceRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}

// MARK: - SwiftData Models

@Model
final class CachedEmployee {
    @Attribute(.unique) var id: String
    var displayName: String
    var givenName: String?
    var surname: String?
    var mail: String?
    var jobTitle: String?
    var mobilePhone: String?
    var department: String?
    var photoData: Data?
    var lastSyncedAt: Date

    init(from employee: Employee) {
        self.id = employee.id
        self.displayName = employee.displayName
        self.givenName = employee.givenName
        self.surname = employee.surname
        self.mail = employee.mail
        self.jobTitle = employee.jobTitle
        self.mobilePhone = employee.mobilePhone
        self.department = employee.department
        self.photoData = employee.photoData
        self.lastSyncedAt = Date()
    }

    func toEmployee() -> Employee {
        Employee(
            id: id,
            displayName: displayName,
            givenName: givenName,
            surname: surname,
            mail: mail,
            jobTitle: jobTitle,
            mobilePhone: mobilePhone,
            department: department,
            photoData: photoData
        )
    }
}

@Model
final class CachedAbsenceRecord {
    @Attribute(.unique) var id: String
    var employeeId: String
    var employeeName: String
    var managerId: String
    var managerName: String
    var absenceTypeRaw: String
    var durationRaw: String
    var startDate: Date
    var endDate: Date?
    var customTypeName: String?
    var comment: String?
    var teamGroupId: String?
    var notificationSent: Bool
    var statusRaw: String
    var createdAt: Date
    var isSynced: Bool
    var lastSyncedAt: Date

    init(from record: AbsenceRecord, isSynced: Bool = true) {
        self.id = record.id
        self.employeeId = record.employeeId
        self.employeeName = record.employeeName
        self.managerId = record.managerId
        self.managerName = record.managerName
        self.absenceTypeRaw = record.absenceType.rawValue
        self.durationRaw = record.duration.rawValue
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.customTypeName = record.customTypeName
        self.comment = record.comment
        self.teamGroupId = record.teamGroupId
        self.notificationSent = record.notificationSent
        self.statusRaw = record.status.rawValue
        self.createdAt = record.createdAt
        self.isSynced = isSynced
        self.lastSyncedAt = Date()
    }

    func toAbsenceRecord() -> AbsenceRecord {
        AbsenceRecord(
            id: id,
            employeeId: employeeId,
            employeeName: employeeName,
            managerId: managerId,
            managerName: managerName,
            absenceType: AbsenceType(rawValue: absenceTypeRaw) ?? .sygdom,
            duration: AbsenceDuration(rawValue: durationRaw) ?? .fullDay,
            startDate: startDate,
            endDate: endDate,
            customTypeName: customTypeName,
            comment: comment,
            teamGroupId: teamGroupId,
            notificationSent: notificationSent,
            status: AbsenceStatus(rawValue: statusRaw) ?? .active,
            createdAt: createdAt
        )
    }
}
