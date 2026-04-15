import Foundation
import LocalAuthentication

enum BiometricType {
    case faceID
    case touchID
    case none
}

enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case authenticationFailed(String)
    case cancelled
    case lockout
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            "Biometrisk autentificering er ikke tilgængelig på denne enhed."
        case .notEnrolled:
            "Ingen biometrisk data er registreret. Opsæt Face ID eller Touch ID i Indstillinger."
        case .authenticationFailed(let reason):
            "Autentificering fejlede: \(reason)"
        case .cancelled:
            "Autentificering blev annulleret."
        case .lockout:
            "For mange mislykkede forsøg. Prøv igen senere."
        case .unknown:
            "Ukendt fejl ved biometrisk autentificering."
        }
    }
}

final class BiometricAuthService: @unchecked Sendable {
    private let context = LAContext()

    var availableBiometricType: BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .faceID // Treat optic ID similar to face ID
        @unknown default:
            return .none
        }
    }

    var isBiometricAvailable: Bool {
        availableBiometricType != .none
    }

    var biometricName: String {
        switch availableBiometricType {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .none: "Biometri"
        }
    }

    var biometricIconName: String {
        switch availableBiometricType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .none: "lock.shield"
        }
    }

    func authenticate(reason: String = "Log ind med biometri") async throws {
        let context = LAContext()
        context.localizedCancelTitle = "Annuller"
        context.localizedFallbackTitle = "Brug adgangskode"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error as? LAError {
                throw mapLAError(laError)
            }
            throw BiometricError.notAvailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            if !success {
                throw BiometricError.authenticationFailed("Verificering mislykkedes")
            }
        } catch let laError as LAError {
            throw mapLAError(laError)
        }
    }

    private func mapLAError(_ error: LAError) -> BiometricError {
        switch error.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .userCancel, .appCancel, .systemCancel:
            return .cancelled
        case .biometryLockout:
            return .lockout
        case .authenticationFailed:
            return .authenticationFailed("Biometrisk verificering mislykkedes")
        default:
            return .unknown
        }
    }
}
