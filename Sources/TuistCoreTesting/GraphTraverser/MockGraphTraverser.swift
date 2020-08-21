import Foundation
import TSCBasic
@testable import TuistCore

final class MockGraphTraverser: GraphTraversing {
    var invokedTarget = false
    var invokedTargetCount = 0
    var invokedTargetParameters: (path: AbsolutePath, name: String)?
    var invokedTargetParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedTargetResult: Target!

    func target(path: AbsolutePath, name: String) -> Target? {
        invokedTarget = true
        invokedTargetCount += 1
        invokedTargetParameters = (path, name)
        invokedTargetParametersList.append((path, name))
        return stubbedTargetResult
    }

    var invokedTargets = false
    var invokedTargetsCount = 0
    var invokedTargetsParameters: (path: AbsolutePath, Void)?
    var invokedTargetsParametersList = [(path: AbsolutePath, Void)]()
    var stubbedTargetsResult: [Target]! = []

    func targets(at path: AbsolutePath) -> [Target] {
        invokedTargets = true
        invokedTargetsCount += 1
        invokedTargetsParameters = (path, ())
        invokedTargetsParametersList.append((path, ()))
        return stubbedTargetsResult
    }

    var invokedDirectTargetDependencies = false
    var invokedDirectTargetDependenciesCount = 0
    var invokedDirectTargetDependenciesParameters: (path: AbsolutePath, name: String)?
    var invokedDirectTargetDependenciesParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedDirectTargetDependenciesResult: [Target]! = []

    func directTargetDependencies(path: AbsolutePath, name: String) -> [Target] {
        invokedDirectTargetDependencies = true
        invokedDirectTargetDependenciesCount += 1
        invokedDirectTargetDependenciesParameters = (path, name)
        invokedDirectTargetDependenciesParametersList.append((path, name))
        return stubbedDirectTargetDependenciesResult
    }

    var invokedAppExtensionDependencies = false
    var invokedAppExtensionDependenciesCount = 0
    var invokedAppExtensionDependenciesParameters: (path: AbsolutePath, name: String)?
    var invokedAppExtensionDependenciesParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedAppExtensionDependenciesResult: [Target]! = []

    func appExtensionDependencies(path: AbsolutePath, name: String) -> [Target] {
        invokedAppExtensionDependencies = true
        invokedAppExtensionDependenciesCount += 1
        invokedAppExtensionDependenciesParameters = (path, name)
        invokedAppExtensionDependenciesParametersList.append((path, name))
        return stubbedAppExtensionDependenciesResult
    }

    var invokedResourceBundleDependencies = false
    var invokedResourceBundleDependenciesCount = 0
    var invokedResourceBundleDependenciesParameters: (path: AbsolutePath, name: String)?
    var invokedResourceBundleDependenciesParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedResourceBundleDependenciesResult: [Target]! = []

    func resourceBundleDependencies(path: AbsolutePath, name: String) -> [Target] {
        invokedResourceBundleDependencies = true
        invokedResourceBundleDependenciesCount += 1
        invokedResourceBundleDependenciesParameters = (path, name)
        invokedResourceBundleDependenciesParametersList.append((path, name))
        return stubbedResourceBundleDependenciesResult
    }

    var invokedTestTargetsDependingOn = false
    var invokedTestTargetsDependingOnCount = 0
    var invokedTestTargetsDependingOnParameters: (path: AbsolutePath, name: String)?
    var invokedTestTargetsDependingOnParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedTestTargetsDependingOnResult: [Target]! = []

    func testTargetsDependingOn(path: AbsolutePath, name: String) -> [Target] {
        invokedTestTargetsDependingOn = true
        invokedTestTargetsDependingOnCount += 1
        invokedTestTargetsDependingOnParameters = (path, name)
        invokedTestTargetsDependingOnParametersList.append((path, name))
        return stubbedTestTargetsDependingOnResult
    }

    var invokedDirectStaticDependencies = false
    var invokedDirectStaticDependenciesCount = 0
    var invokedDirectStaticDependenciesParameters: (path: AbsolutePath, name: String)?
    var invokedDirectStaticDependenciesParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedDirectStaticDependenciesResult: [GraphDependencyReference]! = []

    func directStaticDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        invokedDirectStaticDependencies = true
        invokedDirectStaticDependenciesCount += 1
        invokedDirectStaticDependenciesParameters = (path, name)
        invokedDirectStaticDependenciesParametersList.append((path, name))
        return stubbedDirectStaticDependenciesResult
    }

    var invokedLinkableDependencies = false
    var invokedLinkableDependenciesCount = 0
    var invokedLinkableDependenciesParameters: (path: AbsolutePath, name: String)?
    var invokedLinkableDependenciesParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedLinkableDependenciesResult: [GraphDependencyReference]! = []

    func linkableDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        invokedLinkableDependencies = true
        invokedLinkableDependenciesCount += 1
        invokedLinkableDependenciesParameters = (path, name)
        invokedLinkableDependenciesParametersList.append((path, name))
        return stubbedLinkableDependenciesResult
    }

    var invokedLibrariesPublicHeadersFolders = false
    var invokedLibrariesPublicHeadersFoldersCount = 0
    var invokedLibrariesPublicHeadersFoldersParameters: (path: AbsolutePath, name: String)?
    var invokedLibrariesPublicHeadersFoldersParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedLibrariesPublicHeadersFoldersResult: [AbsolutePath]! = []

    func librariesPublicHeadersFolders(path: AbsolutePath, name: String) -> [AbsolutePath] {
        invokedLibrariesPublicHeadersFolders = true
        invokedLibrariesPublicHeadersFoldersCount += 1
        invokedLibrariesPublicHeadersFoldersParameters = (path, name)
        invokedLibrariesPublicHeadersFoldersParametersList.append((path, name))
        return stubbedLibrariesPublicHeadersFoldersResult
    }

    var invokedLibrariesSearchPaths = false
    var invokedLibrariesSearchPathsCount = 0
    var invokedLibrariesSearchPathsParameters: (path: AbsolutePath, name: String)?
    var invokedLibrariesSearchPathsParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedLibrariesSearchPathsResult: [AbsolutePath]! = []

    func librariesSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        invokedLibrariesSearchPaths = true
        invokedLibrariesSearchPathsCount += 1
        invokedLibrariesSearchPathsParameters = (path, name)
        invokedLibrariesSearchPathsParametersList.append((path, name))
        return stubbedLibrariesSearchPathsResult
    }

    var invokedLibrariesSwiftIncludePaths = false
    var invokedLibrariesSwiftIncludePathsCount = 0
    var invokedLibrariesSwiftIncludePathsParameters: (path: AbsolutePath, name: String)?
    var invokedLibrariesSwiftIncludePathsParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedLibrariesSwiftIncludePathsResult: [AbsolutePath]! = []

    func librariesSwiftIncludePaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        invokedLibrariesSwiftIncludePaths = true
        invokedLibrariesSwiftIncludePathsCount += 1
        invokedLibrariesSwiftIncludePathsParameters = (path, name)
        invokedLibrariesSwiftIncludePathsParametersList.append((path, name))
        return stubbedLibrariesSwiftIncludePathsResult
    }

    var invokedRunPathSearchPaths = false
    var invokedRunPathSearchPathsCount = 0
    var invokedRunPathSearchPathsParameters: (path: AbsolutePath, name: String)?
    var invokedRunPathSearchPathsParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedRunPathSearchPathsResult: [AbsolutePath]! = []

    func runPathSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath] {
        invokedRunPathSearchPaths = true
        invokedRunPathSearchPathsCount += 1
        invokedRunPathSearchPathsParameters = (path, name)
        invokedRunPathSearchPathsParametersList.append((path, name))
        return stubbedRunPathSearchPathsResult
    }

    var invokedEmbeddableFrameworks = false
    var invokedEmbeddableFrameworksCount = 0
    var invokedEmbeddableFrameworksParameters: (path: AbsolutePath, name: String)?
    var invokedEmbeddableFrameworksParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedEmbeddableFrameworksResult: [GraphDependencyReference]! = []

    func embeddableFrameworks(path: AbsolutePath, name: String) -> [GraphDependencyReference] {
        invokedEmbeddableFrameworks = true
        invokedEmbeddableFrameworksCount += 1
        invokedEmbeddableFrameworksParameters = (path, name)
        invokedEmbeddableFrameworksParametersList.append((path, name))
        return stubbedEmbeddableFrameworksResult
    }

    var invokedCopyProductDependencies = false
    var invokedCopyProductDependenciesCount = 0
    var invokedCopyProductDependenciesParameters: (path: AbsolutePath, target: Target)?
    var invokedCopyProductDependenciesParametersList = [(path: AbsolutePath, target: Target)]()
    var stubbedCopyProductDependenciesResult: [GraphDependencyReference]! = []

    func copyProductDependencies(path: AbsolutePath, target: Target) -> [GraphDependencyReference] {
        invokedCopyProductDependencies = true
        invokedCopyProductDependenciesCount += 1
        invokedCopyProductDependenciesParameters = (path, target)
        invokedCopyProductDependenciesParametersList.append((path, target))
        return stubbedCopyProductDependenciesResult
    }

    var invokedAllDependencyReferences = false
    var invokedAllDependencyReferencesCount = 0
    var invokedAllDependencyReferencesParameters: (project: Project, Void)?
    var invokedAllDependencyReferencesParametersList = [(project: Project, Void)]()
    var stubbedAllDependencyReferencesResult: [GraphDependencyReference]! = []

    func allDependencyReferences(for project: Project) -> [GraphDependencyReference] {
        invokedAllDependencyReferences = true
        invokedAllDependencyReferencesCount += 1
        invokedAllDependencyReferencesParameters = (project, ())
        invokedAllDependencyReferencesParametersList.append((project, ()))
        return stubbedAllDependencyReferencesResult
    }

    var invokedStaticTargets = false
    var invokedStaticTargetsCount = 0
    var invokedStaticTargetsParameters: (path: AbsolutePath, name: String)?
    var invokedStaticTargetsParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedStaticTargetsResult: Set<Target>! = []

    func staticTargets(path: AbsolutePath, name: String) -> Set<Target> {
        invokedStaticTargets = true
        invokedStaticTargetsCount += 1
        invokedStaticTargetsParameters = (path, name)
        invokedStaticTargetsParametersList.append((path, name))
        return stubbedStaticTargetsResult
    }

    var invokedHostTarget = false
    var invokedHostTargetCount = 0
    var invokedHostTargetParameters: (path: AbsolutePath, name: String)?
    var invokedHostTargetParametersList = [(path: AbsolutePath, name: String)]()
    var stubbedHostTargetResult: Target!

    func hostTarget(path: AbsolutePath, name: String) -> Target? {
        invokedHostTarget = true
        invokedHostTargetCount += 1
        invokedHostTargetParameters = (path, name)
        invokedHostTargetParametersList.append((path, name))
        return stubbedHostTargetResult
    }
}
