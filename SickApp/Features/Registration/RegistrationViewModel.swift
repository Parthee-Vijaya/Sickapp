import Foundation

@Observable
final class RegistrationViewModel {
    // Search
    var searchText = ""
    var employees: [Employee] = []

    // Active absences
    var activeAbsences: [AbsenceRecord] = []
    var confirmRaskmelding: AbsenceRecord?
    var raskmeldt: AbsenceRecord?

    // Selection
    var selectedEmployee: Employee?
    var absenceType: AbsenceType = .sygdom
    var messageToTeam = ""

    // Auto-reply
    var autoReplyText = ""

    // State
    var isLoading = false
    var isSubmitting = false
    var errorMessage: String?
    var submittedRecord: AbsenceRecord?

    private let apiClient: APIClientProtocol
    private let authService: AuthServiceProtocol

    init(apiClient: APIClientProtocol, authService: AuthServiceProtocol) {
        self.apiClient = apiClient
        self.authService = authService
    }

    var filteredEmployees: [Employee] {
        guard !searchText.isEmpty else { return [] }
        let query = searchText.lowercased()
        return employees.filter { employee in
            employee.displayName.lowercased().contains(query) ||
            (employee.department?.lowercased().contains(query) ?? false) ||
            (employee.jobTitle?.lowercased().contains(query) ?? false)
        }
    }

    var isFormValid: Bool {
        selectedEmployee != nil
    }

    var registrationTypes: [AbsenceType] {
        [.sygdom, .barnSygedag]
    }

    func loadData() async {
        isLoading = true
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

    func raskmeld(_ record: AbsenceRecord) async {
        do {
            _ = try await apiClient.updateAbsence(id: record.id, endDate: Date(), status: .ended)
            raskmeldt = record
            activeAbsences.removeAll { $0.id == record.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func dismissRaskmeldt() {
        raskmeldt = nil
    }

    func selectEmployee(_ employee: Employee) {
        selectedEmployee = employee
        searchText = ""
        generateAutoReply()
    }

    func clearSelection() {
        selectedEmployee = nil
        autoReplyText = ""
    }

    func generateAutoReply() {
        guard let employee = selectedEmployee else {
            autoReplyText = ""
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "da_DK")
        dateFormatter.dateStyle = .long

        let today = dateFormatter.string(from: Date())
        let name = employee.displayName

        let typeText: String
        switch absenceType {
        case .sygdom:
            typeText = "sygdom"
        case .barnSygedag:
            typeText = "barnets sygdom"
        default:
            typeText = "fravær"
        }

        autoReplyText = """
        Tak for din mail. Jeg er desværre fraværende pga. \(typeText) fra d. \(today).

        Henvendelser kan i mellemtiden rettes til min leder eller kontoret.

        Jeg vender tilbage hurtigst muligt.

        Med venlig hilsen
        \(name)
        """
    }

    func resetAutoReply() {
        generateAutoReply()
    }

    func submit() async {
        guard isFormValid, let employee = selectedEmployee else { return }

        isSubmitting = true
        errorMessage = nil

        let manager = await authService.currentManager

        let record = AbsenceRecord(
            id: UUID().uuidString,
            employeeId: employee.id,
            employeeName: employee.displayName,
            managerId: manager?.id ?? "",
            managerName: manager?.displayName ?? "",
            absenceType: absenceType,
            duration: .fullDay,
            startDate: Date(),
            endDate: nil,
            customTypeName: nil,
            comment: messageToTeam.isEmpty ? nil : messageToTeam,
            teamGroupId: nil,
            notificationSent: false,
            status: .active,
            createdAt: Date()
        )

        do {
            let created = try await apiClient.createAbsence(record)
            submittedRecord = created
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    func reset() {
        selectedEmployee = nil
        absenceType = .sygdom
        messageToTeam = ""
        autoReplyText = ""
        submittedRecord = nil
        errorMessage = nil
        searchText = ""
        Task { await loadData() }
    }
}
