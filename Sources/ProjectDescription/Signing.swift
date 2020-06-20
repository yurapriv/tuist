import Foundation

public enum Signing: Equatable, Codable {
    case development(teamId: String, configuration: String)
    case distribution(teamId: String, configuration: String)
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case teamId
        case configuration
    }
    
    private enum Kind: String, Codable {
        case development
        case distribution
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        let teamId = try container.decode(String.self, forKey: .teamId)
        let configuration = try container.decode(String.self, forKey: .configuration)
        switch kind {
        case .development:
            self = .development(teamId: teamId, configuration: configuration)
        case .distribution:
            self = .distribution(teamId: teamId, configuration: configuration)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .development(teamId: teamId, configuration: configuration):
            try container.encode(Kind.development, forKey: .kind)
            try container.encode(teamId, forKey: .teamId)
            try container.encode(configuration, forKey: .configuration)
        case let .distribution(teamId: teamId, configuration: configuration):
            try container.encode(Kind.distribution, forKey: .kind)
            try container.encode(teamId, forKey: .teamId)
            try container.encode(configuration, forKey: .configuration)
        }
    }
}
