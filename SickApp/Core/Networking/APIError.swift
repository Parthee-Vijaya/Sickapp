import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case networkError(String)
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case decodingError(String)
    case rateLimited
    case offline
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Ugyldig URL"
        case .networkError(let message):
            "Netværksfejl: \(message)"
        case .unauthorized:
            "Din session er udløbet. Log ind igen."
        case .forbidden:
            "Du har ikke adgang til denne ressource."
        case .notFound:
            "Ressourcen blev ikke fundet."
        case .serverError(let code):
            "Serverfejl (\(code)). Prøv igen senere."
        case .decodingError(let message):
            "Kunne ikke læse data: \(message)"
        case .rateLimited:
            "For mange forespørgsler. Vent lidt og prøv igen."
        case .offline:
            "Ingen internetforbindelse."
        case .unknown(let message):
            "Ukendt fejl: \(message)"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .networkError, .serverError, .rateLimited, .offline:
            true
        default:
            false
        }
    }
}
