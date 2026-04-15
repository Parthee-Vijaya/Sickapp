import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: message)
    }
}
