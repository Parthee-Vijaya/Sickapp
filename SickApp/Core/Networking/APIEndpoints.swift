import Foundation

enum APIEndpoints {
    static let baseURL = "https://fraværsmelder-api.azurewebsites.net/api"

    enum Auth {
        static let me = "\(baseURL)/me"
        static let directReports = "\(baseURL)/me/direct-reports"
        static func employeePhoto(id: String) -> String { "\(baseURL)/employees/\(id)/photo" }
    }

    enum Groups {
        static let myGroups = "\(baseURL)/me/groups"
        static func groupMembers(id: String) -> String { "\(baseURL)/groups/\(id)/members" }
    }

    enum Absences {
        static let create = "\(baseURL)/absences"
        static let list = "\(baseURL)/absences"
        static func detail(id: String) -> String { "\(baseURL)/absences/\(id)" }
        static func extend(id: String) -> String { "\(baseURL)/absences/\(id)/extend" }
        static let stats = "\(baseURL)/absences/stats"
    }

    enum Notifications {
        static let send = "\(baseURL)/notifications/send"
    }
}
