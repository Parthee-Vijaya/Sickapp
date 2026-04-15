import Foundation

enum AbsenceDuration: String, CaseIterable, Codable, Identifiable {
    case fullDay = "hel_dag"
    case morning = "formiddag"
    case afternoon = "eftermiddag"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fullDay: "Hel dag"
        case .morning: "Formiddag"
        case .afternoon: "Eftermiddag"
        }
    }
}
