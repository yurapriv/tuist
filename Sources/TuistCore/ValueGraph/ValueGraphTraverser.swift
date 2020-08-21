import Foundation
import TSCBasic
import TuistSupport

public class ValueGraphTraverser: GraphTraversing {
    private let graph: ValueGraph

    public required init(graph: ValueGraph) {
        self.graph = graph
    }

    public func target(path: AbsolutePath, name: String) -> Target? {
        graph.targets[path]?[name]
    }

    public func targets(at path: AbsolutePath) -> [Target] {
        guard let targets = graph.targets[path] else { return [] }
        return Array(targets.values).sorted()
    }

    public func directTargetDependencies(path: AbsolutePath, name: String) -> [Target] {
        guard let dependencies = graph.dependencies[.target(name: name, path: path)] else { return [] }
        return dependencies.flatMap { (dependency) -> [Target] in
            guard case let ValueGraphDependency.target(dependencyName, dependencyPath) = dependency else { return [] }
            guard let projectDependencies = graph.targets[dependencyPath], let dependencyTarget = projectDependencies[dependencyName] else { return []
            }
            return [dependencyTarget]
        }.sorted()
    }

    public func resourceBundleDependencies(path: AbsolutePath, name: String) -> [Target] {
        guard let target = graph.targets[path]?[name] else { return [] }
        guard target.supportsResources else { return [] }

        let canHostResources: (ValueGraphDependency) -> Bool = {
            self.target(from: $0)?.supportsResources == true
        }

        let isBundle: (ValueGraphDependency) -> Bool = {
            self.target(from: $0)?.product == .bundle
        }

        let bundles = filterDependencies(from: .target(name: name, path: path),
                                         test: isBundle,
                                         skip: canHostResources)
        let bundleTargets = bundles.compactMap(target(from:))

        return bundleTargets.sorted()
    }

    public func testTargetsDependingOn(path: AbsolutePath, name: String) -> [Target] {
        graph.targets[path]?.values
            .filter { $0.product.testsBundle }
            .filter { graph.dependencies[.target(name: $0.name, path: path)]?.contains(.target(name: name, path: path)) == true }
            .sorted() ?? []
    }

    public func target(from dependency: ValueGraphDependency) -> Target? {
        guard case let ValueGraphDependency.target(name, path) = dependency else {
            return nil
        }
        return graph.targets[path]?[name]
    }

    public func appExtensionDependencies(path: AbsolutePath, name: String) -> [Target] {
        let validProducts: [Product] = [
            .appExtension, .stickerPackExtension, .watch2Extension, .messagesExtension,
        ]
        return directTargetDependencies(path: path, name: name)
            .filter { validProducts.contains($0.product) }
            .sorted()
    }

    public func directStaticDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        graph.dependencies[.target(name: name, path: path)]?
            .compactMap { (dependency: ValueGraphDependency) -> (path: AbsolutePath, name: String)? in
                guard case let ValueGraphDependency.target(name, path) = dependency else {
                    return nil
                }
                return (path, name)
            }
            .compactMap { graph.targets[$0.path]?[$0.name] }
            .filter { $0.product.isStatic }
            .map { .product(target: $0.name, productName: $0.productNameWithExtension) }
            .sorted() ?? []
    }

    /// It traverses the depdency graph and returns all the dependencies.
    /// - Parameter path: Path to the project from where traverse the dependency tree.
    public func allDependencies(path: AbsolutePath) -> Set<ValueGraphDependency> {
        guard let targets = graph.targets[path]?.values else { return Set() }

        var references = Set<ValueGraphDependency>()

        targets.forEach { target in
            let dependency = ValueGraphDependency.target(name: target.name, path: path)
            references.formUnion(filterDependencies(from: dependency))
        }

        return references
    }

    /// The method collects the dependencies that are selected by the provided test closure.
    /// The skip closure allows skipping the traversing of a specific dependendency branch.
    /// - Parameters:
    ///   - from: Dependency from which the traverse is done.
    ///   - test: If the closure returns true, the dependency is included.
    ///   - skip: If the closure returns false, the traversing logic doesn't traverse the dependencies from that dependency.
    public func filterDependencies(from rootDependency: ValueGraphDependency,
                                   test: (ValueGraphDependency) -> Bool = { _ in true },
                                   skip: (ValueGraphDependency) -> Bool = { _ in false }) -> Set<ValueGraphDependency>
    {
        var stack = Stack<ValueGraphDependency>()

        stack.push(rootDependency)

        var visited: Set<ValueGraphDependency> = .init()
        var references = Set<ValueGraphDependency>()

        while !stack.isEmpty {
            guard let node = stack.pop() else {
                continue
            }

            if visited.contains(node) {
                continue
            }

            visited.insert(node)

            if node != rootDependency, test(node) {
                references.insert(node)
            }

            if node != rootDependency, skip(node) {
                continue
            }

            graph.dependencies[node]?.forEach { nodeDependency in
                if !visited.contains(nodeDependency) {
                    stack.push(nodeDependency)
                }
            }
        }

        return references
    }

    public func linkableDependencies(path _: AbsolutePath, name _: String) -> [GraphDependencyReference] {
        // TODO:
        []
    }

    public func librariesPublicHeadersFolders(path _: AbsolutePath, name _: String) -> [AbsolutePath] {
        // TODO:
        []
    }

    public func librariesSearchPaths(path _: AbsolutePath, name _: String) -> [AbsolutePath] {
        // TODO:
        []
    }

    public func librariesSwiftIncludePaths(path _: AbsolutePath, name _: String) -> [AbsolutePath] {
        // TODO:
        []
    }

    public func runPathSearchPaths(path _: AbsolutePath, name _: String) -> [AbsolutePath] {
        // TODO:
        []
    }

    public func embeddableFrameworks(path _: AbsolutePath, name _: String) -> [GraphDependencyReference] {
        // TODO:
        []
    }

    public func copyProductDependencies(path _: AbsolutePath, target _: Target) -> [GraphDependencyReference] {
        // TODO:
        []
    }

    public func allDependencyReferences(for _: Project) -> [GraphDependencyReference] {
        // TODO:
        []
    }

    public func staticTargets(path: AbsolutePath, name: String) -> Set<Target> {
        let dependencies = filterDependencies(from: .target(name: name, path: path),
                                              test: isStatic,
                                              skip: canLinkStaticProducts)
        let targets = dependencies.compactMap { (dependency) -> Target? in
            guard case let ValueGraphDependency.target(targetName, projectPath) = dependency else {
                return nil
            }
            return graph.targets[projectPath]?[targetName]
        }
        return Set(targets)
    }

    public func hostTarget(path: AbsolutePath, name: String) -> Target? {
        guard let projectTargets = graph.targets[path] else { return nil }
        return projectTargets.values.first { (target) -> Bool in
            let targetDependencies = graph.dependencies[.target(name: target.name, path: path)]
            return targetDependencies?.contains(.target(name: name, path: path)) == true
        }
    }

    // MARK: - Fileprivate

    fileprivate func isStatic(_ dependency: ValueGraphDependency) -> Bool {
        switch dependency {
        case let .framework(_, _, _, linking, _): return linking == .static
        case let .xcframework(_, _, _, linking): return linking == .static
        case let .library(_, _, linking, _, _): return linking == .static
        case let .target(targetName, projectPath):
            return graph.targets[projectPath]?[targetName]?.product.isStatic == true
        case .packageProduct: return false
        case .sdk: return false
        case .cocoapods: return false
        }
    }

    fileprivate func canLinkStaticProducts(_ dependency: ValueGraphDependency) -> Bool {
        switch dependency {
        case .framework: return true
        case .xcframework: return true
        case .library: return true
        case let .target(targetName, projectPath):
            return graph.targets[projectPath]?[targetName]?.canLinkStaticProducts() == true
        case .packageProduct: return false
        case .sdk: return false
        case .cocoapods: return false
        }
    }
}
