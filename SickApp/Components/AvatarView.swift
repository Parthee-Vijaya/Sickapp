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
                    .font(.system(size: size * 0.38, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(colorForName(name))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func colorForName(_ name: String) -> Color {
        let colors: [Color] = [
            Color(hex: "007AFF"), Color(hex: "34C759"), Color(hex: "FF9500"),
            Color(hex: "AF52DE"), Color(hex: "FF2D55"), Color(hex: "5AC8FA"),
        ]
        let hash = name.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return colors[hash % colors.count]
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
