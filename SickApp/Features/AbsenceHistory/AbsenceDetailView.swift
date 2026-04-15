import SwiftUI

struct AbsenceDetailView: View {
    let record: AbsenceRecord
    let apiClient: APIClientProtocol

    @State private var showEndDatePicker = false
    @State private var selectedEndDate = Date()
    @State private var showCancelConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            // Status header
            Section {
                HStack {
                    Label(record.status.displayName, systemImage: record.isActive ? "circle.fill" : "checkmark.circle.fill")
                        .foregroundStyle(record.isActive ? Color.theme.absent : Color.theme.success)
                    Spacer()
                    Text(record.displayType)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(record.absenceType.color.opacity(0.15))
                        .foregroundStyle(record.absenceType.color)
                        .clipShape(Capsule())
                }
            }

            // Details
            Section("Detaljer") {
                DetailRow(label: "Medarbejder", value: record.employeeName)
                DetailRow(label: "Fraværstype", value: record.displayType)
                DetailRow(label: "Varighed", value: record.duration.displayName)
                DetailRow(label: "Startdato", value: record.startDate.formatted(as: .dayMonthYear))
                if let endDate = record.endDate {
                    DetailRow(label: "Slutdato", value: endDate.formatted(as: .dayMonthYear))
                }
                DetailRow(label: "Dage fraværende", value: "\(record.daysAbsent)")
            }

            // Comment
            if let comment = record.comment, !comment.isEmpty {
                Section("Kommentar") {
                    Text(comment)
                        .font(.body)
                }
            }

            // Notification
            Section("Notifikation") {
                Label(
                    record.notificationSent ? "Sendt" : "Ikke sendt",
                    systemImage: record.notificationSent ? "envelope.fill" : "envelope"
                )
                .foregroundStyle(record.notificationSent ? Color.theme.success : .secondary)
            }

            // Actions
            if record.isActive {
                Section("Handlinger") {
                    Button {
                        showEndDatePicker = true
                    } label: {
                        Label("Sæt slutdato (raskmelding)", systemImage: "calendar.badge.checkmark")
                    }

                    Button {
                        // Resend notification
                        HapticFeedbackManager.notification(.success)
                    } label: {
                        Label("Gensend notifikation", systemImage: "envelope.arrow.triangle.branch")
                    }

                    Button(role: .destructive) {
                        showCancelConfirmation = true
                    } label: {
                        Label("Annuller fraværsregistrering", systemImage: "xmark.circle")
                    }
                }
            }
        }
        .navigationTitle("Fraværsdetalje")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEndDatePicker) {
            NavigationStack {
                DatePicker("Slutdato", selection: $selectedEndDate, in: record.startDate..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                    .navigationTitle("Vælg slutdato")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuller") { showEndDatePicker = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Bekræft") {
                                Task {
                                    _ = try? await apiClient.updateAbsence(id: record.id, endDate: selectedEndDate, status: .ended)
                                    HapticFeedbackManager.notification(.success)
                                    showEndDatePicker = false
                                    dismiss()
                                }
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .confirmationDialog("Annuller fravær", isPresented: $showCancelConfirmation) {
            Button("Annuller fraværsregistrering", role: .destructive) {
                Task {
                    try? await apiClient.cancelAbsence(id: record.id)
                    HapticFeedbackManager.notification(.warning)
                    dismiss()
                }
            }
        } message: {
            Text("Er du sikker på, at du vil annullere fraværsregistreringen for \(record.employeeName)?")
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
    }
}

#Preview {
    NavigationStack {
        AbsenceDetailView(record: PreviewData.absenceRecords[0], apiClient: MockAPIClient())
    }
}
