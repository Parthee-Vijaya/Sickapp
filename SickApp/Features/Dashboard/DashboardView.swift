import SwiftUI

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel

    init(apiClient: APIClientProtocol, authService: AuthServiceProtocol) {
        self._viewModel = State(initialValue: DashboardViewModel(apiClient: apiClient, authService: authService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.greeting)
                                .font(.title2.bold())
                            Text("Her er dit overblik for i dag")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if let manager = viewModel.manager {
                            AvatarView(name: manager.displayName, photoData: manager.photoData, size: 48)
                        }
                    }
                    .padding(.horizontal)

                    // Stats cards
                    HStack(spacing: 12) {
                        StatCard(title: "Fraværende", value: "\(viewModel.absentCount)", color: Color.theme.absent, icon: "person.fill.xmark")
                        StatCard(title: "Team", value: "\(viewModel.teamSize)", color: Color.theme.info, icon: "person.3.fill")
                        StatCard(title: "Tilgæng.", value: "\(viewModel.availabilityPercentage)%", color: Color.theme.available, icon: "checkmark.circle.fill")
                    }
                    .padding(.horizontal)

                    // Active absences
                    if !viewModel.activeAbsences.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Aktive fraværsregistreringer")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.activeAbsences) { record in
                                ActiveAbsenceRow(record: record)
                                    .padding(.horizontal)
                            }
                        }
                    } else if !viewModel.isLoading {
                        ContentUnavailableView(
                            "Ingen fraværende",
                            systemImage: "checkmark.circle",
                            description: Text("Alle medarbejdere er tilgængelige i dag")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Hjem")
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.loadData() }
            .overlay {
                if viewModel.isLoading && viewModel.activeAbsences.isEmpty {
                    ProgressView("Indlæser...")
                }
            }
            .errorBanner(viewModel.errorMessage)
        }
    }
}

// MARK: - Subviews

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

private struct ActiveAbsenceRow: View {
    let record: AbsenceRecord

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(record.absenceType.color)
                .frame(width: 8, height: 8)

            AvatarView(name: record.employeeName, photoData: nil, size: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.employeeName)
                    .font(.subheadline.bold())
                Text(record.displayType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.duration.displayName)
                    .font(.caption)
                Text("\(record.daysAbsent) dag\(record.daysAbsent == 1 ? "" : "e")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(record.absenceType.color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    DashboardView(apiClient: MockAPIClient(), authService: MockAuthService())
}
