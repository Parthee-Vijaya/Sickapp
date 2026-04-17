import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var viewModel: AnalyticsViewModel

    init(apiClient: APIClientProtocol) {
        self._viewModel = State(initialValue: AnalyticsViewModel(apiClient: apiClient))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Period picker
                    Picker("Periode", selection: $viewModel.selectedPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.displayName).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedPeriod) { _, newPeriod in
                        Task { await viewModel.changePeriod(newPeriod, managerId: "") }
                    }

                    if let stats = viewModel.stats {
                        // Total + trend
                        HStack(spacing: 12) {
                            VStack(spacing: 4) {
                                Text("\(stats.totalDays)")
                                    .font(.system(size: 36, weight: .bold))
                                Text("Fraværsdage")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .cardStyle()

                            VStack(spacing: 4) {
                                Image(systemName: viewModel.trendIsPositive ? "arrow.down.right" : "arrow.up.right")
                                    .font(.title2)
                                    .foregroundStyle(viewModel.trendIsPositive ? Color.theme.success : Color.theme.error)
                                Text(viewModel.trendText)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .cardStyle()
                        }
                        .padding(.horizontal)

                        // Type distribution pie chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Fordeling per type")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(stats.byType) { item in
                                SectorMark(
                                    angle: .value("Dage", item.days),
                                    innerRadius: .ratio(0.5),
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
                                    HStack(spacing: 4) {
                                        Circle().fill(item.type.color).frame(width: 8, height: 8)
                                        Text(item.type.displayName)
                                            .font(.caption)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .cardStyle()
                        .padding(.horizontal)

                        // Monthly trend bar chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Trend seneste 6 måneder")
                                .font(.headline)
                                .padding(.horizontal)

                            Chart(stats.monthlyTrend) { item in
                                BarMark(
                                    x: .value("Måned", item.month),
                                    y: .value("Dage", item.days)
                                )
                                .foregroundStyle(Color.theme.primary.gradient)
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        .cardStyle()
                        .padding(.horizontal)

                    } else if viewModel.isLoading {
                        ProgressView("Indlæser statistik...")
                            .padding(.top, 60)
                    }
                }
                .padding(.vertical)
            }
            .background(Color.theme.background)
            .navigationTitle("Statistik")
            .task { await viewModel.loadStats(managerId: "") }
            .errorBanner(viewModel.errorMessage)
        }
    }
}

#Preview {
    AnalyticsView(apiClient: MockAPIClient())
}
