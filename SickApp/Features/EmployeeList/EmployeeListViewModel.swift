import Foundation

@Observable
final class EmployeeListViewModel {
    var employees: [Employee] = []
    var activeAbsences: [AbsenceRecord] = []
    var searchText = ""
    var isLoading = false
    var errorMessage: String?

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var filteredEmployees: [Employee] {
        if searchText.isEmpty {
            return employees
        }
        let query = searchText.lowercased()
        return employees.filter { emp in
            emp.displayName.lowercased().contains(query) ||
            (emp.jobTitle?.lowercased().contains(query) ?? false) ||
            (emp.mail?.lowercased().contains(query) ?? false)
        }
    }

    var absentEmployees: [Employee] {
        let absentIds = Set(activeAbsences.map(\.employeeId))
        return filteredEmployees.filter { absentIds.contains($0.id) }
    }

    var availableEmployees: [Employee] {
        let absentIds = Set(activeAbsences.map(\.employeeId))
        return filteredEmployees.filter { !absentIds.contains($0.id) }
    }

    func absenceFor(employeeId: String) -> AbsenceRecord? {
        activeAbsences.first { $0.employeeId == employeeId }
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            async let employeesResult = apiClient.getDirectReports()
            async let absencesResult = apiClient.getAbsences(managerId: "", status: .active, type: nil)
            employees = try await employeesResult
            activeAbsences = try await absencesResult
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func quickSickReport(for employee: Employee) async throws -> AbsenceRecord {
        let record = AbsenceRecord(
            id: UUID().uuidString,
            employeeId: employee.id,
            employeeName: employee.displayName,
            managerId: "",
            managerName: "",
            absenceType: .sygdom,
            duration: .fullDay,
            startDate: Date(),
            endDate: nil,
            customTypeName: nil,
            comment: nil,
            teamGroupId: nil,
            notificationSent: false,
            status: .active,
            createdAt: Date()
        )
        return try await apiClient.createAbsence(record)
    }
}
