import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var manager: Manager?
    @State private var selectedTab = 0

    // Services - use mocks for development, swap for real implementations
    private let authService: AuthServiceProtocol = MockAuthService()
    private let apiClient: APIClientProtocol = MockAPIClient()
    private let cacheService: CacheServiceProtocol = MockCacheService()

    var body: some View {
        Group {
            if isAuthenticated {
                mainTabView
            } else {
                LoginView(authService: authService) { mgr in
                    manager = mgr
                    isAuthenticated = true
                }
            }
        }
        .animation(.easeInOut, value: isAuthenticated)
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Registrering", systemImage: "plus.circle.fill", value: 0) {
                RegistrationView(apiClient: apiClient, authService: authService)
            }

            Tab("Hjem", systemImage: "house.fill", value: 1) {
                DashboardView(apiClient: apiClient, authService: authService)
            }

            Tab("Team", systemImage: "person.3.fill", value: 2) {
                EmployeeListView(apiClient: apiClient)
            }

            Tab("Historik", systemImage: "clock.fill", value: 3) {
                AbsenceHistoryView(apiClient: apiClient)
            }

            Tab("Indstillinger", systemImage: "gearshape.fill", value: 4) {
                SettingsView(
                    authService: authService,
                    apiClient: apiClient,
                    cacheService: cacheService,
                    onLogout: {
                        isAuthenticated = false
                        manager = nil
                    }
                )
            }
        }
        .tint(Color.theme.primary)
    }
}

#Preview {
    ContentView()
}
