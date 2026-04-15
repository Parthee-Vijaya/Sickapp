import Foundation

/// Production authentication service using MSAL.
/// NOTE: Requires MSAL SDK to be added via SPM for full functionality.
/// For development/preview, use MockAuthService instead.
final class AuthenticationService: AuthServiceProtocol, @unchecked Sendable {
    private let tokenManager = TokenManager()
    private var _currentManager: Manager?

    var isAuthenticated: Bool {
        get async { await tokenManager.isTokenValid }
    }

    var currentManager: Manager? {
        get async { _currentManager }
    }

    var accessToken: String? {
        get async { await tokenManager.currentToken }
    }

    func signIn() async throws -> Manager {
        // MSAL sign-in flow would go here
        // For now, throw an error indicating MSAL is not configured
        throw APIError.unknown("MSAL er ikke konfigureret. Brug MockAuthService til udvikling.")
    }

    func signOut() async throws {
        await tokenManager.clearToken()
        _currentManager = nil
    }

    func refreshToken() async throws -> String {
        // MSAL silent token refresh would go here
        throw APIError.unauthorized
    }

    func acquireTokenSilently() async throws -> String {
        if let token = await tokenManager.currentToken {
            return token
        }
        return try await refreshToken()
    }
}
