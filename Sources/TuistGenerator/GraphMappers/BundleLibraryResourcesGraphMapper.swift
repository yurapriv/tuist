import Foundation
import TuistCore
import TuistSupport

public class BundleLibraryResourcesGraphMapper: GraphMapping {
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - GraphMapping

    public func map(graph: Graph) throws -> (Graph, [SideEffectDescriptor]) {
        let targetNodeGraphMapper = TargetNodeGraphMapper(transform: map)
        return targetNodeGraphMapper.map(graph: graph)
    }

    // MARK: - Fileprivate

    fileprivate func map(targetNode: TargetNode) -> (TargetNode, [SideEffectDescriptor]) {
        let target = targetNode.target
        var project = targetNode.project
        
        let productsWithoutResources: [Product] = [.dynamicLibrary, .staticLibrary, .staticFramework]
        let doesntSupportResources = productsWithoutResources.contains(target.product)

        let resources = target.resources
        let targetWithoutResources = target.with(resources: [])
        var dependencies = targetNode.dependencies
        let sideEffects: [SideEffectDescriptor] = []

        let fileDescriptor: FileDescriptor
        if doesntSupportResources {
            let bundleName = "\(target.name)-Resources"
            let bundle = Target(name: bundleName,
                                platform: target.platform,
                                product: .bundle,
                                productName: nil,
                                bundleId: "\(target.bundleId).resources",
                resources: resources,
                filesGroup: .group(name: "Project"))
            
            let bundleNode = TargetNode(project: targetNode.project, target: bundle, dependencies: [])
            dependencies.append(bundleNode)
            fileDescriptor = self.fileDescriptor(targetNode: targetNode, doesntSupportResources: doesntSupportResources, bundleName: bundleName)
            project = project.with(targets: project.targets + [bundle])
        } else {
            fileDescriptor = self.fileDescriptor(targetNode: targetNode, doesntSupportResources: doesntSupportResources)
        }
        
        let targetWithExtensions = targetWithoutResources.with(sources: target.sources + [(path: fileDescriptor.path, compilerFlags: nil)])

        return (TargetNode(project: project,
                           target: targetWithExtensions,
                           dependencies: dependencies), sideEffects)
    }
    
    fileprivate func fileDescriptor(targetNode: TargetNode, doesntSupportResources: Bool, bundleName: String? = nil) -> FileDescriptor {
        let content: String
        if doesntSupportResources {
            content = """
            import Foundation
            
            public extension Bundle {
                static var \(targetNode.target.name): Bundle {
                    Bundle.init(url: Bundle.main.url(forResource: "\(bundleName!)", withExtension: "bundle")!)!
                }
            }
            """
        } else {
            content = """
            import Foundation
            
            fileprivate class \(targetNode.target.name)BundleClass {}
            public extension Bundle {
                static var \(targetNode.target.name): Bundle {
                   Bundle.init(for:  \(targetNode.target.name)BundleClass)
                }
            }
            """
        }
        let path = targetNode.project.path
            .appending(component: Constants.DerivedFolder.name)
            .appending(component: Constants.DerivedFolder.extensions)
            .appending(component: "Bundle+\(targetNode.target.name).swift")
        let data = content.data(using: .utf8)!
        
        return .init(path: path, contents: data, state: .present)
    }
    
}


