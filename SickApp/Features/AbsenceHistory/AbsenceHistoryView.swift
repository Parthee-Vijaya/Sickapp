import SwiftUI

struct AbsenceHistoryView: View {
    @State private var viewModel: AbsenceHistoryViewModel

    init(apiClient: APIClientProtocol) {
        self._viewModel = State(initialValue: AbsenceHistoryViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toggle and filter
                HStack {
                    Picker("Visning", selection: $viewModel.showCalendarView) {
                        Image(systemName: "list.bullet").tag(false)
                        Image(systemName: "calendar").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)

                    Spacer()

                    Menu {
                        Button("Alle typer") { viewModel.selectedTypeFilter = nil }
                        ForEach(AbsenceType.allCases) { type in
                            Button(type.displayName) { viewModel.selectedTypeFilter = type }
                        }
                    } label: {
                        Label(
                            viewModel.selectedTypeFilter?.displayName ?? "Filter",
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                        .font(.subheadline)
                    }
                }
                .padding()

                if viewModel.showCalendarView {
                    calendarView
                } else {
                    listView
                }
            }
            .navigationTitle("Historik")
            .refreshable { await viewModel.loadData(managerId: "") }
            .task { await viewModel.loadData(managerId: "") }
            .overlay {
                if viewModel.isLoading && viewModel.records.isEmpty {
                    ProgressView("Indlæser historik...")
                }
            }
            .errorBanner(viewModel.errorMessage)
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.recordsByMonth, id: \.key) { month, records in
                Section(month) {
                    ForEach(records) { record in
                        NavigationLink {
                            AbsenceDetailView(record: record, apiClient: MockAPIClient())
                        } label: {
                            HistoryRow(record: record)
                        }
                    }
                }
            }
        }
    }

    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredRecords) { record in
                    NavigationLink {
                        AbsenceDetailView(record: record, apiClient: MockAPIClient())
                    } label: {
                        CalendarRow(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

private struct HistoryRow: View {
    let record: AbsenceRecord

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(record.absenceType.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(record.employeeName)
                    .font(.subheadline.weight(.medium))
                Text(record.displayType)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.startDate.formatted(as: .short))
                    .font(.caption)
                Text(record.status.displayName)
                    .font(.caption2)
                    .foregroundStyle(record.isActive ? Color.theme.absent : .secondary)
            }
        }
    }
}

private struct CalendarRow: View {
    let record: AbsenceRecord

    var body: some View {
        HStack(spacing: 12) {
            // Date badge
            VStack(spacing: 2) {
                Text(record.startDate.formatted(as: .weekday).prefix(3).uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(Calendar.current.component(.day, from: record.startDate))")
                    .font(.title3.bold())
            }
            .frame(width: 44)

            Rectangle()
                .fill(record.absenceType.color)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))

            VStack(alignment: .leading, spacing: 4) {
                Text(record.employeeName)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 8) {
                    Text(record.displayType)
                    Text("·")
                    Text(record.duration.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.theme.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AbsenceHistoryView(apiClient: MockAPIClient())
}
