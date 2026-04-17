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
                    // Hero card (Muzli-inspired dark card)
                    heroSection

                    // Quick stats row
                    quickStatsRow

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
            .background(Color.theme.background)
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

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Greeting row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.greeting)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                    Text("Dit overblik")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                if let manager = viewModel.manager {
                    AvatarView(name: manager.displayName, photoData: manager.photoData, size: 48)
                }
            }

            // Gradient KPI card inside hero (Muzli pattern)
            HStack(spacing: 0) {
                kpiItem(value: "\(viewModel.absentCount)", label: "Fraværende", sublabel: "i dag")
                Divider()
                    .frame(height: 40)
                    .overlay(Color.white.opacity(0.3))
                kpiItem(value: "\(viewModel.availabilityPercentage)%", label: "Tilgæng.", sublabel: "af teamet")
                Divider()
                    .frame(height: 40)
                    .overlay(Color.white.opacity(0.3))
                kpiItem(value: "\(viewModel.teamSize)", label: "Team", sublabel: "medarbejdere")
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(
                LinearGradient(
                    colors: [Color.theme.gradientTerracotta, Color.theme.gradientCoral, Color.theme.gradientAmber],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .heroCard()
        .padding(.horizontal)
    }

    private func kpiItem(value: String, label: String, sublabel: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.9))
            Text(sublabel)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick Stats

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            StatCard(title: "Fraværende", value: "\(viewModel.absentCount)", color: Color.theme.absent, icon: "person.fill.xmark")
            StatCard(title: "Team", value: "\(viewModel.teamSize)", color: Color.theme.info, icon: "person.3.fill")
            StatCard(title: "Tilgæng.", value: "\(viewModel.availabilityPercentage)%", color: Color.theme.available, icon: "checkmark.circle.fill")
        }
        .padding(.horizontal)
    }
}

// MARK: - Subviews

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .symbolEffect(.bounce, value: appeared)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .onAppear { appeared = true }
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
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(record.absenceType.color.opacity(0.15), lineWidth: 0.5)
        )
        .shadow(color: Color.theme.cardShadow, radius: 8, y: 4)
    }
}

#Preview {
    DashboardView(apiClient: MockAPIClient(), authService: MockAuthService())
}
