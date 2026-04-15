import SwiftUI

struct RegistrationView: View {
    @State private var viewModel: RegistrationViewModel

    init(apiClient: APIClientProtocol, authService: AuthServiceProtocol) {
        self._viewModel = State(initialValue: RegistrationViewModel(apiClient: apiClient, authService: authService))
    }

    var body: some View {
        NavigationStack {
            Group {
                if let submitted = viewModel.submittedRecord {
                    confirmationContent(record: submitted)
                } else {
                    formContent
                }
            }
            .navigationTitle("Registrering")
            .task { await viewModel.loadData() }
        }
    }

    // MARK: - Form

    private var formContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Active absences
                if !viewModel.activeAbsences.isEmpty {
                    activeAbsencesSection
                }

                // Search section
                searchSection

                // Selected employee
                if let employee = viewModel.selectedEmployee {
                    selectedEmployeeCard(employee)
                    absenceTypeSection
                    messageSection
                    autoReplySection
                    submitButton
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .errorBanner(viewModel.errorMessage)
        .confirmationDialog(
            "Raskmeld \(viewModel.confirmRaskmelding?.employeeName ?? "")?",
            isPresented: Binding(
                get: { viewModel.confirmRaskmelding != nil },
                set: { if !$0 { viewModel.confirmRaskmelding = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Raskmeld") {
                if let record = viewModel.confirmRaskmelding {
                    Task { await viewModel.raskmeld(record) }
                }
            }
            Button("Annuller", role: .cancel) {}
        } message: {
            Text("Fraværet afsluttes med dags dato.")
        }
        .overlay {
            if let record = viewModel.raskmeldt {
                raskmeldtOverlay(record: record)
            }
        }
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Søg medarbejder")
                .font(.headline)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Navn, afdeling eller stilling...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.theme.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Search results
            if !viewModel.filteredEmployees.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.filteredEmployees) { employee in
                            Button {
                                viewModel.selectEmployee(employee)
                            } label: {
                                HStack(spacing: 12) {
                                    AvatarView(name: employee.displayName, photoData: employee.photoData, size: 40)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(employee.displayName)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(.primary)
                                        if let title = employee.jobTitle {
                                            Text(title)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

                                    Spacer()

                                    if let dept = employee.department {
                                        Text(dept)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 12)
                            }

                            if employee.id != viewModel.filteredEmployees.last?.id {
                                Divider()
                                    .padding(.leading, 64)
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
                .background(Color.theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Selected Employee

    private func selectedEmployeeCard(_ employee: Employee) -> some View {
        HStack(spacing: 14) {
            AvatarView(name: employee.displayName, photoData: employee.photoData, size: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(employee.displayName)
                    .font(.headline)
                if let title = employee.jobTitle {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let dept = employee.department {
                    Text(dept)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Button {
                viewModel.clearSelection()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Absence Type

    private var absenceTypeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Fraværstype")
                .font(.headline)

            Picker("Type", selection: $viewModel.absenceType) {
                ForEach(viewModel.registrationTypes) { type in
                    Label(type.displayName, systemImage: type.iconName)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.absenceType) { _, _ in
                viewModel.generateAutoReply()
            }
        }
    }

    // MARK: - Message to Team

    private var messageSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Besked til teamet")
                .font(.headline)
            Text("Valgfri intern besked")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $viewModel.messageToTeam)
                .frame(minHeight: 80)
                .padding(8)
                .background(Color.theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(alignment: .topLeading) {
                    if viewModel.messageToTeam.isEmpty {
                        Text("Skriv en besked til teamet...")
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 16)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Auto Reply

    private var autoReplySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Autosvar til e-mail")
                        .font(.headline)
                    Text("Forslag til fraværsbesked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    viewModel.resetAutoReply()
                } label: {
                    Label("Gendan", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                }
            }

            TextEditor(text: $viewModel.autoReplyText)
                .frame(minHeight: 140)
                .padding(8)
                .background(Color.theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
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
        .padding(.top, 8)
    }

    // MARK: - Confirmation

    private func confirmationContent(record: AbsenceRecord) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.theme.success.opacity(0.15))
                    .frame(width: 120, height: 120)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.theme.success)
            }

            Text("Fravær registreret")
                .font(.title2.bold())

            VStack(spacing: 12) {
                confirmationRow(label: "Medarbejder", value: record.employeeName)
                confirmationRow(label: "Type", value: record.displayType)
                confirmationRow(label: "Dato", value: record.startDate.formatted(as: .dayMonthYear))
            }
            .cardStyle()
            .padding(.horizontal)

            if !viewModel.autoReplyText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Autosvar kopieret", systemImage: "doc.on.doc")
                        .font(.subheadline.bold())
                        .foregroundStyle(Color.theme.success)
                    Text(viewModel.autoReplyText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                .padding()
                .background(Color.theme.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    HapticFeedbackManager.impact(.medium)
                    viewModel.reset()
                } label: {
                    Text("Registrer endnu en")
                        .primaryButtonStyle()
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .onAppear {
            HapticFeedbackManager.notification(.success)
        }
    }

    private func confirmationRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Active Absences

    private var activeAbsencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(Color.theme.absent)
                Text("Fraværende nu")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.activeAbsences.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.activeAbsences) { record in
                Button {
                    viewModel.confirmRaskmelding = record
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(record.absenceType.color)
                            .frame(width: 8, height: 8)

                        AvatarView(name: record.employeeName, photoData: nil, size: 36)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(record.employeeName)
                                .font(.subheadline.bold())
                                .foregroundStyle(.primary)
                            Text(record.displayType)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(record.daysAbsent) dag\(record.daysAbsent == 1 ? "" : "e")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Tryk for raskmeld")
                                .font(.caption2)
                                .foregroundStyle(Color.theme.success)
                        }
                    }
                    .padding(12)
                    .background(record.absenceType.color.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding()
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Raskmeldt Overlay

    private func raskmeldtOverlay(record: AbsenceRecord) -> some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.theme.success.opacity(0.15))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.theme.success)
            }

            Text("\(record.employeeName) er raskmeldt")
                .font(.title3.bold())

            Text("Fraværet er afsluttet med dags dato.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button {
                viewModel.dismissRaskmeldt()
            } label: {
                Text("OK")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onAppear {
            HapticFeedbackManager.notification(.success)
        }
    }
}

#Preview {
    RegistrationView(apiClient: MockAPIClient(), authService: MockAuthService())
}
