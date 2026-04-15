import Foundation

final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    static var registeredAbsences: [AbsenceRecord] = []

    var shouldFail = false
    var isEmpty = false
    var delay: Duration = .milliseconds(300)

    func getMe() async throws -> Manager {
        try await simulateNetwork()
        return PreviewData.manager
    }

    func getDirectReports() async throws -> [Employee] {
        try await simulateNetwork()
        return isEmpty ? [] : PreviewData.employees
    }

    func getEmployeePhoto(employeeId: String) async throws -> Data {
        try await simulateNetwork()
        return Data()
    }

    func getMyGroups() async throws -> [TeamGroup] {
        try await simulateNetwork()
        return isEmpty ? [] : PreviewData.teamGroups
    }

    func getGroupMembers(groupId: String) async throws -> [Employee] {
        try await simulateNetwork()
        return isEmpty ? [] : PreviewData.employees
    }

    func createAbsence(_ record: AbsenceRecord) async throws -> AbsenceRecord {
        try await simulateNetwork()
        MockAPIClient.registeredAbsences.append(record)
        return record
    }

    func getAbsences(managerId: String, status: AbsenceStatus?, type: AbsenceType?) async throws -> [AbsenceRecord] {
        try await simulateNetwork()
        if isEmpty { return [] }
        var records = PreviewData.absenceRecords + MockAPIClient.registeredAbsences
        if let status { records = records.filter { $0.status == status } }
        if let type { records = records.filter { $0.absenceType == type } }
        return records
    }

    func getAbsence(id: String) async throws -> AbsenceRecord {
        try await simulateNetwork()
        let allRecords = PreviewData.absenceRecords + MockAPIClient.registeredAbsences
        guard let record = allRecords.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }
        return record
    }

    func updateAbsence(id: String, endDate: Date?, status: AbsenceStatus?) async throws -> AbsenceRecord {
        try await simulateNetwork()
        var record = try await getAbsence(id: id)
        if let endDate { record.endDate = endDate }
        if let status { record.status = status }
        // Update in registeredAbsences if it exists there
        if let index = MockAPIClient.registeredAbsences.firstIndex(where: { $0.id == id }) {
            MockAPIClient.registeredAbsences[index] = record
        }
        return record
    }

    func cancelAbsence(id: String) async throws {
        try await simulateNetwork()
        if let index = MockAPIClient.registeredAbsences.firstIndex(where: { $0.id == id }) {
            MockAPIClient.registeredAbsences[index].status = .cancelled
        }
    }

    func extendAbsence(id: String, newEndDate: Date) async throws -> AbsenceRecord {
        try await simulateNetwork()
        var record = try await getAbsence(id: id)
        record.endDate = newEndDate
        return record
    }

    func getAbsenceStats(managerId: String, period: StatsPeriod) async throws -> AbsenceStats {
        try await simulateNetwork()
        return PreviewData.absenceStats
    }

    func sendNotification(absenceId: String, groupId: String) async throws {
        try await simulateNetwork()
    }

    private func simulateNetwork() async throws {
        if shouldFail { throw APIError.networkError("Mock netværksfejl") }
        try? await Task.sleep(for: delay)
    }
}
