import SwiftUI

struct AbsenceReportView: View {
    @State private var viewModel: AbsenceReportViewModel
    @Environment(\.dismiss) private var dismiss

    init(apiClient: APIClientProtocol, employee: Employee? = nil) {
        self._viewModel = State(initialValue: AbsenceReportViewModel(apiClient: apiClient, employee: employee))
    }

    var body: some View {
        Group {
            if let submitted = viewModel.submittedRecord {
                ConfirmationView(
                    record: submitted,
                    groupName: viewModel.selectedGroup?.displayName,
                    memberCount: viewModel.selectedGroup?.memberCount ?? 0,
                    onRegisterAnother: {
                        viewModel.reset()
                    },
                    onDone: { dismiss() }
                )
            } else {
                formContent
            }
        }
        .navigationTitle("Registrer fravær")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuller") { dismiss() }
            }
        }
        .task { await viewModel.loadGroups() }
    }

    private var formContent: some View {
        Form {
            // Employee info
            if let employee = viewModel.selectedEmployee {
                Section {
                    HStack(spacing: 12) {
                        AvatarView(name: employee.displayName, photoData: employee.photoData, size: 50)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(employee.displayName)
                                .font(.headline)
                            if let title = employee.jobTitle {
                                Text(title)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let mail = employee.mail {
                                Text(mail)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }

            // Absence type
            Section("Fraværstype") {
                Picker("Type", selection: $viewModel.absenceType) {
                    ForEach(AbsenceType.allCases) { type in
                        Label(type.displayName, systemImage: type.iconName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)

                if viewModel.absenceType == .andet {
                    TextField("Beskriv fraværstype", text: $viewModel.customTypeName)
                }
            }

            // Duration
            Section("Varighed") {
                Picker("Varighed", selection: $viewModel.duration) {
                    ForEach(AbsenceDuration.allCases) { dur in
                        Text(dur.displayName).tag(dur)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Dates
            Section("Datoer") {
                DatePicker("Startdato", selection: $viewModel.startDate, displayedComponents: .date)

                Toggle("Slutdato", isOn: $viewModel.hasEndDate)
                if viewModel.hasEndDate {
                    DatePicker("Slutdato", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                }
            }

            // Comment
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $viewModel.comment)
                        .frame(minHeight: 80)
                        .onChange(of: viewModel.comment) { _, _ in
                            viewModel.checkGDPRCompliance()
                        }

                    HStack {
                        if viewModel.showGDPRWarning {
                            Label("Undgå at angive diagnoser eller helbredsoplysninger", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.theme.warning)
                        }
                        Spacer()
                        Text("\(viewModel.commentCharacterCount)/500")
                            .font(.caption2)
                            .foregroundStyle(viewModel.isCommentTooLong ? Color.theme.error : .secondary)
                    }
                }
            } header: {
                Text("Kommentar (valgfri)")
            }

            // Notification
            Section("Notifikation") {
                Toggle("Send notifikation til team", isOn: $viewModel.sendNotification)

                if viewModel.sendNotification && !viewModel.teamGroups.isEmpty {
                    Picker("Vælg gruppe", selection: $viewModel.selectedGroup) {
                        ForEach(viewModel.teamGroups) { group in
                            Text("\(group.displayName) (\(group.memberCount) pers.)")
                                .tag(Optional(group))
                        }
                    }
                }
            }

            // Submit
            Section {
                Button {
                    HapticFeedbackManager.impact(.heavy)
                    Task { await viewModel.submit() }
                } label: {
                    HStack {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Registrer fravær")
                    }
                    .primaryButtonStyle()
                }
                .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            if let error = viewModel.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(Color.theme.error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AbsenceReportView(
            apiClient: MockAPIClient(),
            employee: PreviewData.employees[0]
        )
    }
}
