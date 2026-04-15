import Foundation

@Observable
final class AbsenceReportViewModel {
    // Form fields
    var selectedEmployee: Employee?
    var absenceType: AbsenceType = .sygdom
    var duration: AbsenceDuration = .fullDay
    var startDate = Date()
    var hasEndDate = false
    var endDate = Date()
    var customTypeName = ""
    var comment = ""
    var sendNotification = true
    var selectedGroup: TeamGroup?

    // State
    var isSubmitting = false
    var errorMessage: String?
    var submittedRecord: AbsenceRecord?
    var showGDPRWarning = false
    var teamGroups: [TeamGroup] = []

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol, employee: Employee? = nil) {
        self.apiClient = apiClient
        self.selectedEmployee = employee
    }

    var commentCharacterCount: Int { comment.count }
    var isCommentTooLong: Bool { comment.count > 500 }

    var isFormValid: Bool {
        selectedEmployee != nil &&
        !isCommentTooLong &&
        (absenceType != .andet || !customTypeName.isEmpty) &&
        (!hasEndDate || endDate >= startDate)
    }

    private static let sensitiveWords = [
        "diagnose", "depression", "angst", "stress", "kræft", "cancer",
        "hiv", "aids", "abort", "graviditet", "psykisk", "alkohol",
        "misbrug", "handicap", "diabetes", "epilepsi", "hjerteproblemer"
    ]

    func checkGDPRCompliance() {
        let lowered = comment.lowercased()
        showGDPRWarning = Self.sensitiveWords.contains { lowered.contains($0) }
    }

    func loadGroups() async {
        do {
            teamGroups = try await apiClient.getMyGroups()
            if selectedGroup == nil {
                selectedGroup = teamGroups.first
            }
        } catch {
            // Groups are optional, don't show error
        }
    }

    func submit() async {
        guard isFormValid, let employee = selectedEmployee else { return }

        isSubmitting = true
        errorMessage = nil

        let record = AbsenceRecord(
            id: UUID().uuidString,
            employeeId: employee.id,
            employeeName: employee.displayName,
            managerId: "",
            managerName: "",
            absenceType: absenceType,
            duration: duration,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            customTypeName: absenceType == .andet ? customTypeName : nil,
            comment: comment.isEmpty ? nil : comment,
            teamGroupId: selectedGroup?.id,
            notificationSent: false,
            status: .active,
            createdAt: Date()
        )

        do {
            let created = try await apiClient.createAbsence(record)

            if sendNotification, let groupId = selectedGroup?.id {
                try? await apiClient.sendNotification(absenceId: created.id, groupId: groupId)
            }

            submittedRecord = created
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    func reset() {
        absenceType = .sygdom
        duration = .fullDay
        startDate = Date()
        hasEndDate = false
        endDate = Date()
        customTypeName = ""
        comment = ""
        sendNotification = true
        selectedGroup = teamGroups.first
        submittedRecord = nil
        errorMessage = nil
        showGDPRWarning = false
    }
}
