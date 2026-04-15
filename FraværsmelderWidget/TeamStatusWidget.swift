import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct TeamStatusProvider: TimelineProvider {
    func placeholder(in context: Context) -> TeamStatusEntry {
        TeamStatusEntry(date: Date(), absentEmployees: TeamStatusEntry.sampleAbsent)
    }

    func getSnapshot(in context: Context, completion: @escaping (TeamStatusEntry) -> Void) {
        completion(TeamStatusEntry(date: Date(), absentEmployees: TeamStatusEntry.sampleAbsent))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TeamStatusEntry>) -> Void) {
        let entry = TeamStatusEntry(date: Date(), absentEmployees: TeamStatusEntry.sampleAbsent)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Entry

struct TeamStatusEntry: TimelineEntry {
    let date: Date
    let absentEmployees: [AbsentEmployee]

    struct AbsentEmployee: Identifiable {
        let id: String
        let name: String
        // Note: Widget does not show absence type for GDPR privacy
    }

    static let sampleAbsent: [AbsentEmployee] = [
        AbsentEmployee(id: "1", name: "Maria Nielsen"),
        AbsentEmployee(id: "2", name: "Sofia Andersen"),
    ]
}

// MARK: - Widget View

struct TeamStatusWidgetView: View {
    var entry: TeamStatusEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundStyle(.blue)
                Text("Teamstatus")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if entry.absentEmployees.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Alle tilgængelige")
                        .font(.subheadline.weight(.medium))
                }
                .padding(.top, 4)
            } else {
                Text("\(entry.absentEmployees.count) fraværende")
                    .font(.subheadline.bold())
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.absentEmployees.prefix(4)) { employee in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.red.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .overlay {
                                    Text(initials(for: employee.name))
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundStyle(.red)
                                }

                            Text(employee.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }

                    if entry.absentEmployees.count > 4 {
                        Text("+\(entry.absentEmployees.count - 4) mere")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

// MARK: - Widget Configuration

struct TeamStatusWidget: Widget {
    let kind = "TeamStatusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TeamStatusProvider()) { entry in
            TeamStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("Teamstatus")
        .description("Se hvem der er fraværende i dit team.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    TeamStatusWidget()
} timeline: {
    TeamStatusEntry(date: Date(), absentEmployees: TeamStatusEntry.sampleAbsent)
    TeamStatusEntry(date: Date(), absentEmployees: [])
}
