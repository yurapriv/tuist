import Foundation
import TSCBasic

public protocol GraphTraversing {
    /// It returns the target with the given name in the project that is defined in the given directory path.
    /// - Parameters:
    ///   - path: Path to the directory that contains the definition of the project with the target is defined.
    ///   - name: Name of the target.
    func target(path: AbsolutePath, name: String) -> Target?

    /// It returns the targets of the project defined in the directory at the given path.
    /// - Parameter path: Path to the directory that contains the definition of the project.
    func targets(at path: AbsolutePath) -> [Target]

    /// Given a project directory and target name, it returns all its direct target dependencies.
    /// - Parameters:
    ///   - path: Path to the directory that contains the project.
    ///   - name: Target name.
    func directTargetDependencies(path: AbsolutePath, name: String) -> [Target]

    /// Given a project directory and a target name, it returns all the dependencies that are extensions.
    /// - Parameters:
    ///   - path: Path to the directory that contains the project.
    ///   - name: Target name.
    func appExtensionDependencies(path: AbsolutePath, name: String) -> [Target]

    /// Returns the transitive resource bundle dependencies for the given target.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func resourceBundleDependencies(path: AbsolutePath, name: String) -> [Target]

    /// Returns the list of test targets that depend on the one with the given name at the given path.
    /// - Parameters:
    ///   - path: Path to the directory that contains the project definition.
    ///   - name: Name of the target whose dependant test targets will be returned.
    func testTargetsDependingOn(path: AbsolutePath, name: String) -> [Target]

    /// Returns all non-transitive target static dependencies for the given target.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func directStaticDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference]

    /// It returns the libraries a given target should be linked against.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func linkableDependencies(path: AbsolutePath, name: String) -> [GraphDependencyReference]

    /// Returns the paths for the given target to be able to import the headers from its library dependencies.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func librariesPublicHeadersFolders(path: AbsolutePath, name: String) -> [AbsolutePath]

    /// Returns the search paths for the given target to be able to link its library dependencies.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func librariesSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath]

    /// Returns all the include paths of the library dependencies form the given target.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func librariesSwiftIncludePaths(path: AbsolutePath, name: String) -> [AbsolutePath]

    /// Returns all runpath search paths of the given target
    /// Currently applied only to test targets with no host application
    /// - Parameters:
    ///     - path; Path to the directory where the project that defines the target
    ///     - name: Name of the target
    func runPathSearchPaths(path: AbsolutePath, name: String) -> [AbsolutePath]

    /// Returns the list of products that should be embedded into the product of the given target.
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - name: Name of the target.
    func embeddableFrameworks(path: AbsolutePath, name: String) -> [GraphDependencyReference]

    /// Returns that are added to a dummy copy files phase to enforce build order between dependencies that Xcode doesn't usually respect (e.g. Resouce Bundles)
    /// - Parameters:
    ///   - path: Path to the directory where the project that defines the target is located.
    ///   - target: Target.
    func copyProductDependencies(path: AbsolutePath, target: Target) -> [GraphDependencyReference]

    /// For the given project it returns all its expected dependency references.
    /// This method is useful to know which references should be added to the products directory in the generated project.
    /// - Parameter path: Path to the project whose dependency references will be returned.
    func allDependencyReferences(path: AbsolutePath) -> [GraphDependencyReference]

    /// Returns all the transitive dependencies of the given target that are static libraries.
    /// - Parameter target: Target whose transitive static libraries will be returned.
    func staticTargets(path: AbsolutePath, name: String) -> Set<Target>

    /// Retuns the first host target for a given target
    ///
    /// (e.g. finding host application for an extension)
    ///
    /// - Parameter path: Path of the hosted target
    /// - Parameter name: Name of the hosted target
    ///
    /// - Note: Search is limited to nodes with a matching path (i.e. targets within the same project)
    func hostTarget(path: AbsolutePath, name: String) -> Target?
}
