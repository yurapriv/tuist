import Foundation
import TSCBasic

public final class GraphTraverser: GraphTraversing {
    private let graph: Graph
    public init(graph: Graph) {
        self.graph = graph
    }

    public func target(path: AbsolutePath, name: String) -> Target? {
        graph.target(path: path, name: name).map(\.target)
    }

    public func targets(at path: AbsolutePath) -> [Target] {
        graph.targets(at: path).map(\.target)
    }

    public func directTargetDependencies(path: AbsolutePath, name: String) -> [Target] {
        graph.targetDependencies(path: path, name: name).map { $0.target }
    }

    public func appExtensionDependencies(path: AbsolutePath, name: String) -> [Target] {
        graph.appExtensionDependencies(path: path, name: name).map { $0.target }
    }

    public func resourceBundleDependencies(path: AbsolutePath, name: String) -> [Target] {
        graph.resourceBundleDependencies(path: path, name: name).map { $0.target }
    }

    public func testTargetsDependingOn(path: AbsolutePath, name: String) -> [Target] {
        graph.testTargetsDependingOn(path: path, name: name).map(\.target)
    }

    public func directStaticDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        graph.staticDependencies(path: path, name: name)
    }

    public func linkableDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        graph.linkableDependencies(path: path, name: name)
    }

    public func librariesPublicHeadersFolders(path: AbsolutePath, name: String) -> [AbsolutePath] {
        graph.librariesPublicHeadersFolders(path: path, name: name)
    }

    public func librariesSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        graph.librariesSearchPaths(path: path, name: name)
    }

    public func librariesSwiftIncludePaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        graph.librariesSwiftIncludePaths(path: path, name: name)
    }

    public func runPathSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        graph.runPathSearchPaths(path: path, name: name)
    }

    public func embeddableFrameworks(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        graph.embeddableFrameworks(path: path, name: name)
    }

    public func copyProductDependencies(path: AbsolutePath, target: Target) -> [GraphDependencyReference] {
        graph.copyProductDependencies(path: path, target: target)
    }

    public func allDependencyReferences(path: AbsolutePath) -> [GraphDependencyReference] {
        guard let project = graph.projects.first(where: {$0.path == path}) else { return [] }
        return graph.allDependencyReferences(for: project)
    }

    public func staticTargets(path: AbsolutePath, name: String) -> Set<Target> {
        guard let targetNode = graph.targets[path]?.first(where: { $0.name == name }) else { return Set() }
        return Set(graph.transitiveStaticTargetNodes(for: targetNode).map(\.target))
    }

    public func hostTarget(path: AbsolutePath, name: String) -> Target? {
        graph.hostTargetNodeFor(path: path, name: name)?.target
    }
}
