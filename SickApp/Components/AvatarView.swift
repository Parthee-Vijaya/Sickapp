import SwiftUI

struct AvatarView: View {
    let name: String
    let photoData: Data?
    var size: CGFloat = 44

    private var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var body: some View {
        Group {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            colors: gradientForName(name),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
    }

    private func gradientForName(_ name: String) -> [Color] {
        let gradients: [[Color]] = [
            [Color(hex: "BC4D30"), Color(hex: "E8725C")],  // Kalundborg terracotta
            [Color(hex: "2ECC71"), Color(hex: "5BA4A4")],  // Green → teal
            [Color(hex: "F4A261"), Color(hex: "E84855")],  // Amber → coral
            [Color(hex: "8B3A2A"), Color(hex: "BC4D30")],  // Dark terracotta
            [Color(hex: "E8725C"), Color(hex: "F4A261")],  // Coral → amber
            [Color(hex: "5BA4A4"), Color(hex: "1A1B2E")],  // Teal → navy
        ]
        let hash = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return gradients[hash % gradients.count]
    }
}

#Preview {
    VStack(spacing: 16) {
        AvatarView(name: "Maria Nielsen", photoData: nil, size: 60)
        AvatarView(name: "Peter Hansen", photoData: nil, size: 44)
        AvatarView(name: "Sofia Andersen", photoData: nil, size: 32)
    }
    .padding()
}
