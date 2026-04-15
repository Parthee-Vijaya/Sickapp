import Foundation

actor TokenManager {
    private var accessToken: String?
    private var tokenExpiration: Date?

    var currentToken: String? {
        guard let token = accessToken, let expiration = tokenExpiration, expiration > Date() else {
            return nil
        }
        return token
    }

    var isTokenValid: Bool {
        currentToken != nil
    }

    func updateToken(_ token: String, expiresIn seconds: TimeInterval) {
        self.accessToken = token
        self.tokenExpiration = Date().addingTimeInterval(seconds)
    }

    func clearToken() {
        accessToken = nil
        tokenExpiration = nil
    }
}
