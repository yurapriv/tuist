import Foundation
import TSCBasic

/// Interface to get the build settings of a given target.
/// Note that since we don't know about Xcode's defaults, we don't
/// include them when flattening.
/// Target build settings - Target xcconfig - Project settings - Project xcconfig
protocol BuildSettingsFlattening {
    func reduce(target: Target, project: Project) throws -> [String: String]
}

final class BuildSettingsFlattener: BuildSettingsFlattening {
    
    func reduce(target: Target, project: Project) throws -> [String: String] {
        
        
        return [:]
    }
    
    // MARK: - Private
    
    private func readXcodeBuildConfigFile(path: AbsolutePath) -> [String: String] {
        return [:]
    }
    
}
