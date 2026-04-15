import Foundation

struct TeamGroup: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    let mail: String?
    var members: [Employee]

    var memberCount: Int { members.count }
}
