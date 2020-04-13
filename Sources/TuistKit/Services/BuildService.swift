import Basic
import Foundation
import RxBlocking
import SPMUtility
import TuistAutomation
import TuistCore
import TuistLoader
import TuistSupport

enum BuildServiceError: FatalError {
    case missingManifest(AbsolutePath)
    case nonBuildableTarget(String)

    // Error description
    var description: String {
        switch self {
        case let .missingManifest(path):
            return "Couldn't find Project.swift or Workspace.swift at \(path.pathString)."
        case let .nonBuildableTarget(scheme):
            return "Couldn't find a target \(scheme). Make sure the auto-generation of schemes is enabled."
        }
    }

    // Error type
    var type: ErrorType { .abort }
}

final class BuildService {
    // MARK: - Fileprivate

    private let xcodebuildController: XcodeBuildControlling
    private let manifestLoader: ManifestLoading
    private let graphLoader: GraphLoading
    private let generator: ProjectGenerating

    // MARK: - Init

    convenience init() {
        let xcodebuildController = XcodeBuildController()
        let manifestLoader = ManifestLoader()
        let manifestLinter = AnyManifestLinter()
        let generatorModelLoader = GeneratorModelLoader(manifestLoader: manifestLoader,
                                                        manifestLinter: manifestLinter)
        let graphLoader = GraphLoader(modelLoader: generatorModelLoader)
        self.init(xcodebuildController: xcodebuildController,
                  manifestLoader: manifestLoader,
                  graphLoader: graphLoader,
                  generator: ProjectGenerator())
    }

    init(xcodebuildController: XcodeBuildControlling,
         manifestLoader: ManifestLoading,
         graphLoader: GraphLoading,
         generator: ProjectGenerating) {
        self.xcodebuildController = xcodebuildController
        self.manifestLoader = manifestLoader
        self.graphLoader = graphLoader
        self.generator = generator
    }

    func run(target: String?, path: AbsolutePath, clean: Bool) throws {
        var xcodebuildTarget: XcodeBuildTarget! = self.xcodebuildTarget(path: path)
        var graph: Graph!

        if xcodebuildTarget == nil {
            logger.notice("Couldn't find a workspace at \(path.pathString). Generating the projects...")

            let workspacePath: AbsolutePath
            (workspacePath, graph) = try generator.generateWithGraph(path: path, projectOnly: false)
            xcodebuildTarget = .workspace(workspacePath)
        } else {
            logger.notice("Workspace \(xcodebuildTarget.path.basename) found. Skipping project generation...")
            graph = try loadGraph(path: path)
        }

        if let targetName = target {
            let targets = buildableTargets(graph: graph)
            guard let target = targets.first(where: { $0.name == targetName }) else {
                throw BuildServiceError.nonBuildableTarget(targetName)
            }

            // Build the given schemes
            logger.pretty("Building target \(.bold(.raw(target.name)))", metadata: .section)
            _ = try xcodebuildController.build(xcodebuildTarget,
                                               scheme: target.name,
                                               clean: clean,
                                               arguments: [
                                                   .sdk(target.platform.xcodeDeviceSDK),
                                               ])
                .printFormattedOutput()
                .toBlocking()
                .last()
        } else {
            // Build all the targets of the project in the given directory
            var firstBuilt: Bool = false
            let entryTargets = self.entryTargets(graph: graph)

            try entryTargets.forEach { target in
                logger.pretty("Building target \(.bold(.raw(target.name)))", metadata: .section)
                _ = try xcodebuildController.build(xcodebuildTarget,
                                                   scheme: target.name,
                                                   clean: clean && !firstBuilt,
                                                   arguments: [
                                                       .sdk(target.platform.xcodeDeviceSDK),
                                                   ])
                    .printFormattedOutput()
                    .toBlocking()
                    .last()
                firstBuilt = true
            }
        }
    }

    // MARK: - Private

    private func buildableTargets(graph: Graph) -> Set<Target> {
        Set(graph.targets
            .flatMap { $0.value }
            .compactMap { ($0.project.autogenerateSchemes && !$0.target.product.testsBundle) ? $0.target : nil })
    }

    private func entryTargets(graph: Graph) -> Set<Target> {
        Set(graph.entryNodes
            .compactMap { $0 as? TargetNode }
            .compactMap { ($0.project.autogenerateSchemes && !$0.target.product.testsBundle) ? $0.target : nil })
    }

    private func loadGraph(path: AbsolutePath) throws -> Graph {
        let manifests = manifestLoader.manifests(at: path)
        if manifests.contains(.workspace) {
            return try graphLoader.loadWorkspace(path: path).0
        } else if manifests.contains(.project) {
            return try graphLoader.loadProject(path: path).0
        } else {
            throw BuildServiceError.missingManifest(path)
        }
    }

    private func xcodebuildTarget(path: AbsolutePath) -> XcodeBuildTarget? {
        if let workspacePath = path.glob("*.xcworkspace").first {
            return .workspace(workspacePath)
        }
        return nil
    }
}
