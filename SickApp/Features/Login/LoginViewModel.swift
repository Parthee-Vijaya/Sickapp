import Foundation

@Observable
final class LoginViewModel {
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false
    var manager: Manager?
    var showBiometricOption = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            let mgr = try await authService.signIn()
            manager = mgr
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithBiometric() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await authService.acquireTokenSilently()
            if let mgr = await authService.currentManager {
                manager = mgr
                isAuthenticated = true
            }
        } catch {
            errorMessage = "Biometrisk login mislykkedes. Prøv med Microsoft login."
        }
        isLoading = false
    }

    func checkExistingSession() async {
        if await authService.isAuthenticated {
            manager = await authService.currentManager
            isAuthenticated = manager != nil
            showBiometricOption = true
        }
    }
}
