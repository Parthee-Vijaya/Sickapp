import SwiftUI

struct StatusIndicator: View {
    let isAbsent: Bool
    var absenceType: AbsenceType?
    var size: CGFloat = 12

    var body: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(Color.theme.cardBackground, lineWidth: 2)
            )
            .shadow(color: indicatorColor.opacity(0.5), radius: isAbsent ? 4 : 0)
            .symbolEffect(.pulse, isActive: isAbsent)
    }

    private var indicatorColor: Color {
        if isAbsent {
            return absenceType?.color ?? Color.theme.absent
        }
        return Color.theme.available
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 20) {
            StatusIndicator(isAbsent: false)
            Text("Tilgængelig")
        }
        HStack(spacing: 20) {
            StatusIndicator(isAbsent: true, absenceType: .sygdom)
            Text("Sygdom")
        }
        HStack(spacing: 20) {
            StatusIndicator(isAbsent: true, absenceType: .barnSygedag)
            Text("Barnets sygedag")
        }
    }
    .padding()
}
