import Foundation

struct APIKey: Codable {
    let teamId: String
    let issuerId: String
    let apiKeyId: String
    let privateKey: String
}
