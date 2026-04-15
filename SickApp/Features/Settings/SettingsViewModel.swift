import Foundation

@Observable
final class SettingsViewModel {
    var manager: Manager?
    var useBiometric = true
    var defaultGroupId: String?
    var receiveEmailCopy = false
    var appearance: AppAppearance = .system
    var compactMode = false
    var isLoading = false
    var teamGroups: [TeamGroup] = []

    private let authService: AuthServiceProtocol
    private let apiClient: APIClientProtocol
    private let cacheService: CacheServiceProtocol

    init(authService: AuthServiceProtocol, apiClient: APIClientProtocol, cacheService: CacheServiceProtocol) {
        self.authService = authService
        self.apiClient = apiClient
        self.cacheService = cacheService
    }

    func loadSettings() async {
        manager = await authService.currentManager
        do {
            teamGroups = try await apiClient.getMyGroups()
        } catch {
            // Optional - don't block UI
        }
    }

    func clearCache() async {
        isLoading = true
        try? await cacheService.clearAllCache()
        isLoading = false
    }

    func signOut() async throws {
        try await authService.signOut()
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case light = "Lys"
    case dark = "Mørk"
    case system = "System"

    var id: String { rawValue }
}
