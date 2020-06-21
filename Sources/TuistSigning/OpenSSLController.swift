import Foundation
import TSCBasic
import TuistSupport

protocol OpenSSLControlling {
    func generatePrivateKey(at path: AbsolutePath) throws
    func createCertificateSigningRequest(privateKey: AbsolutePath, outputPath: AbsolutePath) throws
}

final class OpenSSLController: OpenSSLControlling {
    func generatePrivateKey(at path: AbsolutePath) throws {
        try System.shared.run("openssl", "genrsa", "-out", path.pathString, "2048")
    }
    
    func createCertificateSigningRequest(privateKey: AbsolutePath, outputPath: AbsolutePath) throws {
        try System.shared.run("openssl", "req", "-new", "-sha256", "-key", privateKey.pathString, "-out", outputPath.pathString)
    }
}
