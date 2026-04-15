import Foundation

struct Employee: Codable, Identifiable, Hashable {
    let id: String
    let displayName: String
    let givenName: String?
    let surname: String?
    let mail: String?
    let jobTitle: String?
    let mobilePhone: String?
    let department: String?
    var photoData: Data?

    var initials: String {
        let parts = displayName.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case givenName
        case surname
        case mail
        case jobTitle
        case mobilePhone
        case department
        case photoData
    }
}
