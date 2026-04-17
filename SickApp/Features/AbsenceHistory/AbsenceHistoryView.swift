import SwiftUI
import Charts

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
                    Picker("Visning", selection: $viewModel.displayMode) {
                        Image(systemName: "list.bullet").tag(HistoryDisplayMode.list)
                        Image(systemName: "calendar").tag(HistoryDisplayMode.calendar)
                        Image(systemName: "chart.bar.fill").tag(HistoryDisplayMode.statistics)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)

                    Spacer()

                    if viewModel.displayMode != .statistics {
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
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.theme.glassBorder, lineWidth: 0.5)
                            )
                        }
                    }
                }
                .padding()

                switch viewModel.displayMode {
                case .list:
                    listView
                case .calendar:
                    calendarView
                case .statistics:
                    statisticsView
                }
            }
            .background(Color.theme.background)
            .navigationTitle("Historik")
            .refreshable { await viewModel.loadData(managerId: "") }
            .task { await viewModel.loadData(managerId: "") }
            .task { await viewModel.loadStats(managerId: "") }
            .overlay {
                if viewModel.isLoading && viewModel.records.isEmpty {
                    ProgressView("Indlæser historik...")
                }
            }
            .errorBanner(viewModel.errorMessage)
        }
    }

    // MARK: - List View

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

    // MARK: - Calendar View

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

    // MARK: - Statistics View

    private var statisticsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Period picker
                Picker("Periode", selection: $viewModel.selectedStatsPeriod) {
                    ForEach(StatsPeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedStatsPeriod) { _, _ in
                    Task { await viewModel.loadStats(managerId: "") }
                }

                if let stats = viewModel.stats {
                    // KPI Cards
                    kpiCardsSection(stats: stats)

                    // Monthly Trend Line Chart
                    monthlyTrendSection(stats: stats)

                    // Type Distribution Donut
                    typeDistributionSection(stats: stats)

                    // Weekday Heatmap
                    weekdaySection(stats: stats)

                    // Bradford Factor
                    bradfordSection(stats: stats)
                } else {
                    ProgressView("Indlæser statistik...")
                        .padding(.top, 40)
                }
            }
            .padding(.vertical)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - KPI Cards

    private func kpiCardsSection(stats: AbsenceStats) -> some View {
        HStack(spacing: 10) {
            // Average per month
            VStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title3)
                    .foregroundStyle(Color.theme.primary)
                Text(String(format: "%.1f", stats.averageDaysPerMonth))
                    .font(.system(size: 24, weight: .bold))
                Text("Gns./md.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .cardStyle()

            // Absence percentage
            VStack(spacing: 6) {
                Image(systemName: "percent")
                    .font(.title3)
                    .foregroundStyle(Color.theme.warning)
                Text(String(format: "%.1f%%", stats.absencePercentage))
                    .font(.system(size: 24, weight: .bold))
                Text("Fravær")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .cardStyle()

            // Trend
            VStack(spacing: 6) {
                let trendDown = stats.trendPercentage <= 0
                Image(systemName: trendDown ? "arrow.down.right" : "arrow.up.right")
                    .font(.title3)
                    .foregroundStyle(trendDown ? Color.theme.success : Color.theme.error)
                Text(String(format: "%+.0f%%", stats.trendPercentage))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(trendDown ? Color.theme.success : Color.theme.error)
                Text("Trend")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .cardStyle()
        }
        .padding(.horizontal)
    }

    // MARK: - Monthly Trend

    private func monthlyTrendSection(stats: AbsenceStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Månedlig trend")
                .font(.headline)
                .padding(.horizontal)

            Chart(stats.monthlyTrend) { item in
                AreaMark(
                    x: .value("Måned", item.month),
                    y: .value("Dage", item.days)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.primary.opacity(0.3), Color.theme.primary.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Måned", item.month),
                    y: .value("Dage", item.days)
                )
                .foregroundStyle(Color.theme.primary)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))

                PointMark(
                    x: .value("Måned", item.month),
                    y: .value("Dage", item.days)
                )
                .foregroundStyle(Color.theme.primary)
                .symbolSize(30)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.theme.glassBorder)
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Type Distribution

    private func typeDistributionSection(stats: AbsenceStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fordeling per type")
                .font(.headline)
                .padding(.horizontal)

            Chart(stats.byType) { item in
                SectorMark(
                    angle: .value("Dage", item.days),
                    innerRadius: .ratio(0.55),
                    angularInset: 2
                )
                .foregroundStyle(item.type.color)
                .annotation(position: .overlay) {
                    Text("\(item.days)d")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)

            // Legend
            HStack(spacing: 16) {
                ForEach(stats.byType) { item in
                    HStack(spacing: 6) {
                        Circle().fill(item.type.color).frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.type.displayName)
                                .font(.caption.weight(.medium))
                            Text("\(item.count) gange, \(item.days) dage")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Weekday Heatmap

    private func weekdaySection(stats: AbsenceStats) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Fravær per ugedag")
                    .font(.headline)
                Spacer()
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            Chart(stats.byWeekday) { item in
                BarMark(
                    x: .value("Ugedag", item.weekday),
                    y: .value("Antal", item.count)
                )
                .foregroundStyle(
                    barColor(for: item.count, max: stats.byWeekday.map(\.count).max() ?? 1)
                )
                .cornerRadius(6)
                .annotation(position: .top, spacing: 4) {
                    Text("\(item.count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                        .foregroundStyle(Color.theme.glassBorder)
                }
            }
            .frame(height: 180)
            .padding(.horizontal)

            Text("Mandag og fredag har flest sygemeldinger")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Bradford Factor

    private func bradfordSection(stats: AbsenceStats) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Bradford Factor")
                        .font(.headline)
                    Text("S\u{00B2} \u{00D7} D = \(stats.totalRecords)\u{00B2} \u{00D7} \(stats.totalDays)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(stats.bradfordFactor)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(bradfordColor(score: stats.bradfordFactor))
            }
            .padding(.horizontal)

            // Bradford scale
            HStack(spacing: 0) {
                bradfordScaleSegment(label: "Lav", range: "0–49", color: Color.theme.success, isActive: stats.bradfordFactor < 50)
                bradfordScaleSegment(label: "Middel", range: "50–199", color: Color.theme.warning, isActive: stats.bradfordFactor >= 50 && stats.bradfordFactor < 200)
                bradfordScaleSegment(label: "Moderat", range: "200–499", color: .orange, isActive: stats.bradfordFactor >= 200 && stats.bradfordFactor < 500)
                bradfordScaleSegment(label: "Hoj", range: "500+", color: Color.theme.error, isActive: stats.bradfordFactor >= 500)
            }
            .padding(.horizontal)

            Text("Hyppige korte fravær giver hojere score end lange sammenhængende perioder.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func barColor(for count: Int, max: Int) -> Color {
        let ratio = Double(count) / Double(max)
        if ratio > 0.75 { return Color.theme.error }
        if ratio > 0.5 { return Color.theme.warning }
        return Color.theme.primary
    }

    private func bradfordColor(score: Int) -> Color {
        if score < 50 { return Color.theme.success }
        if score < 200 { return Color.theme.warning }
        if score < 500 { return .orange }
        return Color.theme.error
    }

    private func bradfordScaleSegment(label: String, range: String, color: Color, isActive: Bool) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color.opacity(isActive ? 1.0 : 0.3))
                .frame(height: 6)
            Text(label)
                .font(.caption2.weight(isActive ? .bold : .regular))
                .foregroundStyle(isActive ? color : .secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Row

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

// MARK: - Calendar Row

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
                    Text("\u{00B7}")
                    Text(record.duration.displayName)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.theme.cardShadow, radius: 8, y: 4)
    }
}

#Preview {
    AbsenceHistoryView(apiClient: MockAPIClient())
}
