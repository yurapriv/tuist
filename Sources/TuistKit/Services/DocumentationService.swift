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
//    private let manifestLoader: ManifestLoading = ManifestLoader()
//    private let manifestLinter: ManifestLinting = ManifestLinter()
//    private let graphLinter: GraphLinting = GraphLinter()
//    private let environmentLinter: EnvironmentLinting = EnvironmentLinter()
//    private let generator: DescriptorGenerating = DescriptorGenerator()
//    private let writer: XcodeProjWriting = XcodeProjWriter()
//    private let cocoapodsInteractor: CocoaPodsInteracting = CocoaPodsInteractor()
//    private let swiftPackageManagerInteractor: SwiftPackageManagerInteracting = SwiftPackageManagerInteractor()
//    private let modelLoader: GeneratorModelLoading
//    private let graphLoader: GraphLoading
//
//    init() {
//        modelLoader = GeneratorModelLoader(manifestLoader: manifestLoader,
//                                           manifestLinter: manifestLinter)
//        graphLoader = GraphLoader(modelLoader: modelLoader)
//    }

    func run(path _: AbsolutePath) throws {}
}
