import ArgumentParser
import Basic
import Foundation
import TuistSupport

/// Command that builds a target from the project in the current directory.
struct BuildCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(commandName: "build",
                             abstract: "Builds a target or all the buildable targets of a project. To ensure this command works reliabley, it only works when auto-generation of schemes is enabled.")
    }

    @Argument(default: nil, help: "The target to be built. If none is specified, it builds all the buildable targets.")
    var target: String?

    @Flag(name: .shortAndLong,
          help: "Whether xcodebuild should clean before running the build.")
    var clean: Bool

    @Option(name: .shortAndLong,
            default: FileHandler.shared.currentPath,
            help: "The path to the directory that contains the project or workspace.",
            transform: { AbsolutePath($0) })
    var path: AbsolutePath

    func run() throws {
        try BuildService().run(target: target,
                               path: path,
                               clean: clean)
    }
}
