import Foundation

struct Manager: Codable, Identifiable {
    let id: String
    let displayName: String
    let givenName: String?
    let mail: String?
    let jobTitle: String?
    var photoData: Data?

    var firstName: String {
        givenName ?? displayName.split(separator: " ").first.map(String.init) ?? displayName
    }
}
