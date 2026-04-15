import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? self
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }

    func daysUntil(_ other: Date) -> Int {
        let calendar = Calendar.current
        let from = calendar.startOfDay(for: self)
        let to = calendar.startOfDay(for: other)
        return calendar.dateComponents([.day], from: from, to: to).day ?? 0
    }

    func formatted(as style: DateFormatStyle) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "da_DK")
        switch style {
        case .short:
            formatter.dateStyle = .short
        case .medium:
            formatter.dateStyle = .medium
        case .long:
            formatter.dateStyle = .long
        case .dayMonth:
            formatter.dateFormat = "d. MMMM"
        case .dayMonthYear:
            formatter.dateFormat = "d. MMMM yyyy"
        case .weekday:
            formatter.dateFormat = "EEEE"
        case .time:
            formatter.timeStyle = .short
        }
        return formatter.string(from: self)
    }

    var greetingTime: String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 5..<12: return "Godmorgen"
        case 12..<17: return "God eftermiddag"
        case 17..<22: return "God aften"
        default: return "Godnat"
        }
    }

    enum DateFormatStyle {
        case short, medium, long, dayMonth, dayMonthYear, weekday, time
    }
}
