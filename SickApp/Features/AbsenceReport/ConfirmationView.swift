import SwiftUI

struct ConfirmationView: View {
    let record: AbsenceRecord
    let groupName: String?
    let memberCount: Int
    var onRegisterAnother: () -> Void
    var onDone: () -> Void

    @State private var showCheckmark = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Checkmark animation
            ZStack {
                Circle()
                    .fill(Color.theme.success.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.theme.success)
                    .scaleEffect(showCheckmark ? 1 : 0.3)
                    .opacity(showCheckmark ? 1 : 0)
                    .symbolEffect(.bounce, value: showCheckmark)
            }

            Text("Fravær registreret")
                .font(.title2.bold())

            // Summary
            VStack(spacing: 12) {
                SummaryRow(label: "Medarbejder", value: record.employeeName)
                SummaryRow(label: "Type", value: record.displayType)
                SummaryRow(label: "Varighed", value: record.duration.displayName)
                SummaryRow(label: "Startdato", value: record.startDate.formatted(as: .dayMonthYear))
                if let endDate = record.endDate {
                    SummaryRow(label: "Slutdato", value: endDate.formatted(as: .dayMonthYear))
                }
            }
            .glassCard()
            .padding(.horizontal)

            if record.notificationSent, let name = groupName {
                Label("Notifikation sendt til \(name) (\(memberCount) pers.)", systemImage: "envelope.fill")
                    .font(.subheadline)
                    .foregroundStyle(Color.theme.success)
            }

            Spacer()

            // Actions
            VStack(spacing: 12) {
                Button {
                    HapticFeedbackManager.impact(.medium)
                    onRegisterAnother()
                } label: {
                    Text("Registrer endnu et")
                        .primaryButtonStyle()
                }

                Button {
                    onDone()
                } label: {
                    Text("Tilbage til dashboard")
                        .secondaryButtonStyle()
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .onAppear {
            HapticFeedbackManager.notification(.success)
            withAnimation(.spring(duration: 0.5, bounce: 0.4)) {
                showCheckmark = true
            }
        }
    }
}

private struct SummaryRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ConfirmationView(
        record: PreviewData.absenceRecords[0],
        groupName: "Socialteamet",
        memberCount: 5,
        onRegisterAnother: {},
        onDone: {}
    )
}
