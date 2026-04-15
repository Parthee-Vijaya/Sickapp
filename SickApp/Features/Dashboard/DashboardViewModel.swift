import Foundation

@Observable
final class DashboardViewModel {
    var manager: Manager?
    var activeAbsences: [AbsenceRecord] = []
    var directReports: [Employee] = []
    var isLoading = false
    var errorMessage: String?

    private let apiClient: APIClientProtocol
    private let authService: AuthServiceProtocol

    init(apiClient: APIClientProtocol, authService: AuthServiceProtocol) {
        self.apiClient = apiClient
        self.authService = authService
    }

    var greeting: String {
        let name = manager?.firstName ?? "Leder"
        return "\(Date().greetingTime), \(name)"
    }

    var absentCount: Int {
        activeAbsences.count
    }

    var teamSize: Int {
        directReports.count
    }

    var availabilityPercentage: Int {
        guard teamSize > 0 else { return 100 }
        let available = teamSize - absentCount
        return Int(Double(available) / Double(teamSize) * 100)
    }

    var absentEmployeeIds: Set<String> {
        Set(activeAbsences.map(\.employeeId))
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let managerResult = authService.currentManager
            async let reportsResult = apiClient.getDirectReports()
            async let absencesResult = apiClient.getAbsences(
                managerId: manager?.id ?? "",
                status: .active,
                type: nil
            )

            manager = await managerResult
            directReports = try await reportsResult
            activeAbsences = try await absencesResult
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refresh() async {
        await loadData()
    }
}
