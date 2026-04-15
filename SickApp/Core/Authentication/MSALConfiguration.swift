import Foundation

enum MSALConfiguration {
    static let clientId = "YOUR_CLIENT_ID_HERE"
    static let tenantId = "YOUR_TENANT_ID_HERE"
    static let redirectUri = "msauth.com.organisation.fravaersmelder://auth"
    static let authority = "https://login.microsoftonline.com/\(tenantId)"

    static let scopes: [String] = [
        "User.Read",
        "User.Read.All",
        "Group.Read.All",
        "GroupMember.Read.All",
        "Mail.Send"
    ]

    static let keychainGroup = "com.organisation.fravaersmelder"
}
