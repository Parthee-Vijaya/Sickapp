import SwiftUI

struct EmployeeListView: View {
    @State private var viewModel: EmployeeListViewModel
    @State private var selectedEmployee: Employee?

    init(apiClient: APIClientProtocol) {
        self._viewModel = State(initialValue: EmployeeListViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            List {
                if !viewModel.absentEmployees.isEmpty {
                    Section("Fraværende nu") {
                        ForEach(viewModel.absentEmployees) { employee in
                            EmployeeRow(
                                employee: employee,
                                absence: viewModel.absenceFor(employeeId: employee.id)
                            )
                            .onTapGesture {
                                HapticFeedbackManager.selection()
                                selectedEmployee = employee
                            }
                        }
                    }
                }

                Section("Tilgængelige") {
                    ForEach(viewModel.availableEmployees) { employee in
                        EmployeeRow(employee: employee, absence: nil)
                            .onTapGesture {
                                HapticFeedbackManager.selection()
                                selectedEmployee = employee
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    Task {
                                        _ = try? await viewModel.quickSickReport(for: employee)
                                        HapticFeedbackManager.notification(.success)
                                        await viewModel.loadData()
                                    }
                                } label: {
                                    Label("Sygmeld", systemImage: "cross.case.fill")
                                }
                                .tint(Color.theme.sickness)
                            }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Søg navn, titel eller email")
            .navigationTitle("Team")
            .refreshable { await viewModel.loadData() }
            .task { await viewModel.loadData() }
            .sheet(item: $selectedEmployee) { employee in
                NavigationStack {
                    AbsenceReportView(apiClient: MockAPIClient(), employee: employee)
                }
            }
            .overlay {
                if viewModel.isLoading && viewModel.employees.isEmpty {
                    ProgressView("Indlæser medarbejdere...")
                }
            }
            .errorBanner(viewModel.errorMessage)
        }
    }
}

private struct EmployeeRow: View {
    let employee: Employee
    let absence: AbsenceRecord?

    var isAbsent: Bool { absence != nil }

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(name: employee.displayName, photoData: employee.photoData, size: 44)
                StatusIndicator(isAbsent: isAbsent, absenceType: absence?.absenceType, size: 14)
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(employee.displayName)
                    .font(.body.weight(.medium))
                if let title = employee.jobTitle {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if let absence {
                Text(absence.absenceType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(absence.absenceType.color.opacity(0.15))
                    .foregroundStyle(absence.absenceType.color)
                    .clipShape(Capsule())
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    EmployeeListView(apiClient: MockAPIClient())
}
