import Basic
import Foundation

public enum XcodeBuildTarget {
    /// The target is an Xcode project.
    case project(AbsolutePath)

    /// The target is an Xcode workspace.
    case workspace(AbsolutePath)

    /// Returns the arguments that need to be passed to xcodebuild to build this target.
    public var xcodebuildArguments: [String] {
        switch self {
        case let .project(path):
            return ["-project", path.pathString]
        case let .workspace(path):
            return ["-workspace", path.pathString]
        }
    }

    /// Returns the target path.
    public var path: AbsolutePath {
        switch self {
        case let .project(path): return path
        case let .workspace(path): return path
        }
    }
}
