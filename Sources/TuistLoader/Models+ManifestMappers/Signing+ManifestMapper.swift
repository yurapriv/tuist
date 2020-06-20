import Foundation
import ProjectDescription
import TSCBasic
import TuistCore

extension TuistCore.Signing {
    /// Maps a ProjectDescription.Signing instance into a TuistCore.Signing instance.
    /// - Parameters:
    ///   - manifest: Manifest representation of the signing.
    static func from(manifest: ProjectDescription.Signing) throws -> TuistCore.Signing {
        switch manifest {
        case let .development(teamId: teamId, configuration: configuration):
            return .development(teamId: teamId, configuration: configuration)
        case let .distribution(teamId: teamId, configuration: configuration):
            return .distribution(teamId: teamId, configuration: configuration)
        }
    }
}
