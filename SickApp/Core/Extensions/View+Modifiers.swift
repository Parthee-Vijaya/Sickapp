import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.theme.cardShadow, radius: 12, y: 6)
    }

    func glassCard() -> some View {
        self
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.theme.glassBorder, lineWidth: 0.5)
            )
            .shadow(color: Color.theme.cardShadow, radius: 12, y: 6)
    }

    func heroCard() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.theme.darkSurface)
                    .shadow(color: Color.theme.cardShadow, radius: 16, y: 8)
            )
    }

    func warmBackground() -> some View {
        self.background(Color.theme.background)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.theme.primary, Color.theme.primaryLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, y: 4)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(Color.theme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.theme.primary.opacity(0.25), lineWidth: 1)
            )
    }

    func errorBanner(_ message: String?) -> some View {
        self.overlay(alignment: .top) {
            if let message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.error)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: message)
    }
}
