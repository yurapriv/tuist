import Foundation

public enum Signing: Equatable {
    case development(teamId: String, configuration: String)
    case distribution(teamId: String, configuration: String)
}
