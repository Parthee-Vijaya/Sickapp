import Foundation

protocol AuthServiceProtocol: Sendable {
    var isAuthenticated: Bool { get async }
    var currentManager: Manager? { get async }
    var accessToken: String? { get async }

    func signIn() async throws -> Manager
    func signOut() async throws
    func refreshToken() async throws -> String
    func acquireTokenSilently() async throws -> String
}
