import Foundation
import TSCBasic
import TuistSupport

enum APIKeyParserError: FatalError {
    case invalidFormat(String)
    case invalidPrivateKey(String)

    var type: ErrorType {
        switch self {
        case .invalidFormat, .invalidPrivateKey:
            return .abort
        }
    }

    var description: String {
        switch self {
        case let .invalidFormat(apiKey):
            return "API key \(apiKey) is in invalid format. Please name your API keys in the following way: TeamId.APIKeyId.IssuerId.p8"
        case let .invalidPrivateKey(apiKey):
            return "API key at \(apiKey) does not have the correct format. Try to download it again from https://appstoreconnect.apple.com/access/api"
        }
    }
}

protocol APIKeyParsing {
    func parse(at path: AbsolutePath) throws -> APIKey
}

final class APIKeyParser: APIKeyParsing {
    func parse(at path: AbsolutePath) throws -> APIKey {
        let apiKeyComponents = path.basename.components(separatedBy: ".")
        guard apiKeyComponents.count == 4 else { throw APIKeyParserError.invalidFormat(path.pathString) }

        let teamId = apiKeyComponents[0]
        let apiKeyId = apiKeyComponents[1]
        let issuerId = apiKeyComponents[2]

        let privateKeyComponents = try FileHandler.shared.readTextFile(path).components(separatedBy: .newlines)
        guard privateKeyComponents.count >= 3 else { throw APIKeyParserError.invalidPrivateKey(path.pathString) }
        let privateKey = privateKeyComponents[1 ..< privateKeyComponents.endIndex - 1].joined()

        return APIKey(
            teamId: teamId,
            issuerId: issuerId,
            apiKeyId: apiKeyId,
            privateKey: privateKey
        )
    }
}
