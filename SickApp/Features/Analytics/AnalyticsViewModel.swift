import Foundation

@Observable
final class AnalyticsViewModel {
    var stats: AbsenceStats?
    var selectedPeriod: StatsPeriod = .month
    var isLoading = false
    var errorMessage: String?

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    var trendText: String {
        guard let stats else { return "" }
        let pct = stats.trendPercentage
        if pct > 0 {
            return "+\(Int(pct))% ift. forrige periode"
        } else if pct < 0 {
            return "\(Int(pct))% ift. forrige periode"
        }
        return "Uændret ift. forrige periode"
    }

    var trendIsPositive: Bool {
        guard let stats else { return true }
        return stats.trendPercentage <= 0
    }

    func loadStats(managerId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            stats = try await apiClient.getAbsenceStats(managerId: managerId, period: selectedPeriod)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func changePeriod(_ period: StatsPeriod, managerId: String) async {
        selectedPeriod = period
        await loadStats(managerId: managerId)
    }
}
