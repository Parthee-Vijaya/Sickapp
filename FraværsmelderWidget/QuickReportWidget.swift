import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct QuickReportProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuickReportEntry {
        QuickReportEntry(date: Date(), absentCount: 2, teamSize: 8)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuickReportEntry) -> Void) {
        completion(QuickReportEntry(date: Date(), absentCount: 2, teamSize: 8))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuickReportEntry>) -> Void) {
        let entry = QuickReportEntry(date: Date(), absentCount: 2, teamSize: 8)
        // Update every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct QuickReportEntry: TimelineEntry {
    let date: Date
    let absentCount: Int
    let teamSize: Int

    var availableCount: Int { teamSize - absentCount }
    var availabilityPercentage: Int {
        guard teamSize > 0 else { return 100 }
        return Int(Double(availableCount) / Double(teamSize) * 100)
    }
}

// MARK: - Widget View

struct QuickReportWidgetView: View {
    var entry: QuickReportEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.badge.clock.fill")
                    .foregroundStyle(.blue)
                Text("Fravær")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            Text("\(entry.absentCount)")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(entry.absentCount > 0 ? .red : .green)

            Text("fraværende i dag")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            HStack {
                Text("\(entry.availabilityPercentage)%")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                Text("tilgængelig")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget Configuration

struct QuickReportWidget: Widget {
    let kind = "QuickReportWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuickReportProvider()) { entry in
            QuickReportWidgetView(entry: entry)
        }
        .configurationDisplayName("Fravær i dag")
        .description("Se antal fraværende medarbejdere.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    QuickReportWidget()
} timeline: {
    QuickReportEntry(date: Date(), absentCount: 2, teamSize: 8)
    QuickReportEntry(date: Date(), absentCount: 0, teamSize: 8)
}
