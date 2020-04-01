import Basic
import Foundation
import SwiftDoc
import SwiftMarkup
import SwiftSemantics
import struct SwiftSemantics.Protocol
import TuistCore
import TuistLoader

protocol DocumentationServicing {
    func run(path: AbsolutePath) throws
}

final class DocumentationService: DocumentationServicing {
    private let manifestLoader: ManifestLoading
    private let manifestLinter: ManifestLinting
    private let modelLoader: GeneratorModelLoading
    private let graphLoader: GraphLoading
    
    convenience init() {
        let manifestLoader = ManifestLoader()
        let manifestLinter = ManifestLinter()
        let modelLoader = GeneratorModelLoader(manifestLoader: manifestLoader,
                                               manifestLinter: manifestLinter)
        let graphLoader = GraphLoader(modelLoader: modelLoader)
        self.init(manifestLoader: manifestLoader,
                  manifestLinter: manifestLinter,
                  modelLoader: modelLoader,
                  graphLoader: graphLoader)
    }
    
    init(manifestLoader: ManifestLoading,
         manifestLinter: ManifestLinting,
         modelLoader: GeneratorModelLoading,
         graphLoader: GraphLoading) {
        self.manifestLoader = manifestLoader
        self.manifestLinter = manifestLinter
        self.modelLoader = modelLoader
        self.graphLoader = graphLoader
    }

    func run(path: AbsolutePath) throws {
        let graph = try self.loadGraph(at: path)
        let paths = self.paths(from: graph)
        let module = try Module(name: graph.name, paths: paths)


        
    }
    
    fileprivate func paths(from graph: Graph) -> [String] {
        graph.targets.flatMap({ $0.value }).flatMap({ $0.target.sources }).flatMap({ $0.path.pathString })
    }
    
    fileprivate func loadGraph(at path: AbsolutePath) throws -> Graph {
        let manifests = manifestLoader.manifests(at: path)
        let graph: Graph
        if manifests.contains(.workspace) {
            (graph, _) = try graphLoader.loadWorkspace(path: path)
        } else if manifests.contains(.project) {
            (graph, _) = try graphLoader.loadProject(path: path)
        } else {
            throw ManifestLoaderError.manifestNotFound(path)
        }
        return graph
    }
}

//
//
//let outputDirectoryURL = URL(fileURLWithPath: options.output)
//try fileManager.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: fileAttributes)
//
//do {
//    let format = options.format
//

//
//    var globals: [String: [Symbol]] = [:]
//    for symbol in module.interface.topLevelSymbols.filter({ $0.isPublic }) {
//        switch symbol.api {
//        case is Class, is Enumeration, is Structure, is Protocol:
//            pages[path(for: symbol)] = TypePage(module: module, symbol: symbol)
//        case let `typealias` as Typealias:
//            pages[path(for: `typealias`.name)] = TypealiasPage(module: module, symbol: symbol)
//        case let function as Function where !function.isOperator:
//            globals[function.name, default: []] += [symbol]
//        case let variable as Variable:
//            globals[variable.name, default: []] += [symbol]
//        default:
//            continue
//        }
//    }
//
//    for (name, symbols) in globals {
//        pages[path(for: name)] = GlobalPage(module: module, name: name, symbols: symbols)
//    }
//
//    try pages.map { $0 }.parallelForEach {
//        let filename: String
//        switch format {
//        case .commonmark:
//            filename = "\($0.key).md"
//        case .html where $0.key == "Home":
//            filename = "index.html"
//        case .html:
//            filename = "\($0.key)/index.html"
//        }
//
//        let url = outputDirectoryURL.appendingPathComponent(filename)
//        try $0.value.write(to: url, format: format)
//    }
