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
    // MARK: - Kalundborg Kommune Brand
    let primary = Color(hex: "BC4D30")
    let primaryLight = Color(hex: "E8725C")

    // MARK: - Surfaces
    let background = Color(hex: "F5F0EE")
    let secondaryBackground = Color(hex: "F8EDEA")
    let tertiaryBackground = Color(hex: "EDEAE8")
    let groupedBackground = Color(hex: "F5F0EE")
    let cardBackground = Color.white
    let darkSurface = Color(hex: "1A1B2E")
    let darkSurfaceLight = Color(hex: "252640")

    // MARK: - Text
    let label = Color(hex: "1C1C1E")
    let secondaryLabel = Color(hex: "6B6B6E")
    let tertiaryLabel = Color(hex: "9A9A9D")

    // MARK: - Absence type colors
    let sickness = Color(hex: "E84855")
    let childSick = Color(hex: "F4A261")
    let other = Color(hex: "5BA4A4")

    // MARK: - Status colors
    let available = Color(hex: "2ECC71")
    let absent = Color(hex: "E84855")
    let warning = Color(hex: "F4A261")

    // MARK: - Semantic
    let success = Color(hex: "2ECC71")
    let error = Color(hex: "E84855")
    let info = Color(hex: "5BA4A4")

    // MARK: - Gradient palette (warm Kalundborg tones)
    let gradientTerracotta = Color(hex: "BC4D30")
    let gradientCoral = Color(hex: "E8725C")
    let gradientAmber = Color(hex: "F4A261")
    let gradientTeal = Color(hex: "5BA4A4")
    let gradientNavy = Color(hex: "1A1B2E")
    let gradientWarm = Color(hex: "D4836A")

    // Legacy gradient aliases (for LoginView MeshGradient compatibility)
    let gradientBlue = Color(hex: "BC4D30")
    let gradientPurple = Color(hex: "8B3A2A")
    let gradientPink = Color(hex: "E8725C")
    let gradientIndigo = Color(hex: "1A1B2E")
    let gradientMint = Color(hex: "5BA4A4")

    // MARK: - Glass / Material
    let glassTint = Color.white.opacity(0.18)
    let glassBorder = Color.white.opacity(0.2)
    let glassShadow = Color(hex: "BC4D30").opacity(0.06)

    // MARK: - Card shadows
    let cardShadow = Color(hex: "1A1B2E").opacity(0.08)
    let heroGlow = Color(hex: "BC4D30").opacity(0.15)
}
