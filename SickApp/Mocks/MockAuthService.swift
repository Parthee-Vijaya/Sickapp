import Foundation

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    var shouldFail = false
    private var _isAuthenticated = false
    private var _manager: Manager?

    var isAuthenticated: Bool {
        get async { _isAuthenticated }
    }

    var currentManager: Manager? {
        get async { _manager }
    }

    var accessToken: String? {
        get async { _isAuthenticated ? "mock-access-token" : nil }
    }

    func signIn() async throws -> Manager {
        if shouldFail { throw APIError.unauthorized }
        try? await Task.sleep(for: .milliseconds(500))
        let manager = PreviewData.manager
        _manager = manager
        _isAuthenticated = true
        return manager
    }

    func signOut() async throws {
        _isAuthenticated = false
        _manager = nil
    }

    func refreshToken() async throws -> String {
        if shouldFail { throw APIError.unauthorized }
        return "mock-refreshed-token"
    }

    func acquireTokenSilently() async throws -> String {
        if shouldFail { throw APIError.unauthorized }
        return "mock-silent-token"
    }
}
