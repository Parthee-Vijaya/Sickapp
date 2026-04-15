import SwiftUI

extension Color {
    static let theme = ColorTheme()

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ColorTheme {
    // App colors
    let primary = Color(hex: "007AFF")
    let background = Color(.systemBackground)
    let secondaryBackground = Color(.secondarySystemBackground)
    let tertiaryBackground = Color(.tertiarySystemBackground)
    let groupedBackground = Color(.systemGroupedBackground)

    // Text
    let label = Color(.label)
    let secondaryLabel = Color(.secondaryLabel)
    let tertiaryLabel = Color(.tertiaryLabel)

    // Absence type colors
    let sickness = Color(hex: "FF3B30")
    let childSick = Color(hex: "FF9500")
    let other = Color(hex: "007AFF")

    // Status colors
    let available = Color(hex: "34C759")
    let absent = Color(hex: "FF3B30")
    let warning = Color(hex: "FF9500")

    // Semantic
    let success = Color(hex: "34C759")
    let error = Color(hex: "FF3B30")
    let info = Color(hex: "007AFF")
}
