import SwiftUI

enum AbsenceType: String, CaseIterable, Codable, Identifiable {
    case sygdom = "sygdom"
    case barnSygedag = "barn_sygedag"
    case andet = "andet"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sygdom: "Sygdom"
        case .barnSygedag: "Barnets sygedag"
        case .andet: "Andet"
        }
    }

    var color: Color {
        switch self {
        case .sygdom: Color(red: 1.0, green: 0.231, blue: 0.188)       // #FF3B30
        case .barnSygedag: Color(red: 1.0, green: 0.584, blue: 0.0)    // #FF9500
        case .andet: Color(red: 0.0, green: 0.478, blue: 1.0)          // #007AFF
        }
    }

    var iconName: String {
        switch self {
        case .sygdom: "cross.case.fill"
        case .barnSygedag: "figure.and.child.holdinghands"
        case .andet: "ellipsis.circle.fill"
        }
    }
}
