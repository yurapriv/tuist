import Foundation
import TSCBasic

struct Certificate: Equatable, Identifiable {
    let publicKey: AbsolutePath
    let privateKey: AbsolutePath
    let id: String
    let developmentTeam: String
    let name: String
    let targetName: String
    let configurationName: String
    let isRevoked: Bool
}
