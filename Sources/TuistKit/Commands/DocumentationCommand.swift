import Basic
import Foundation
import SPMUtility
import TuistGenerator
import TuistLoader
import TuistSupport

class DocumentationCommand: NSObject, Command {
    // MARK: - Static

    static let command = "doc"
    static let overview = "Generates on-the-fly documentation for a project"

    // MARK: - Attributes

    private let documentationService = DocumentationService()
    private let pathArgument: OptionArgument<String>

    // MARK: - Init

    required init(parser: ArgumentParser) {
        let subParser = parser.add(subparser: DocumentationCommand.command, overview: DocumentationCommand.overview)
        pathArgument = subParser.add(option: "--path",
                                     shortName: "-p",
                                     kind: String.self,
                                     usage: "The path to the directory that contains the project",
                                     completion: .filename)
    }

    func run(with arguments: ArgumentParser.Result) throws {
        let path = self.path(arguments: arguments)
        try documentationService.run(path: path)
    }

    // MARK: - Fileprivate

    private func path(arguments: ArgumentParser.Result) -> AbsolutePath {
        if let path = arguments.get(pathArgument) {
            return AbsolutePath(path, relativeTo: FileHandler.shared.currentPath)
        } else {
            return FileHandler.shared.currentPath
        }
    }
}
