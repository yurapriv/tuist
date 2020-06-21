import Foundation
import RxBlocking
import TSCBasic
import TuistCore
import TuistSupport

enum SigningType {
    case development
    case distribution
}

/// Interacts with signing
public protocol SigningInteracting {
    /// Install signing for a given graph
    func install(graph: Graph) throws
    /// Generates signing for a given graph
    func vendor(graph: Graph) throws
}

public final class SigningInteractor: SigningInteracting {
    /// Dictionary of remote provisioning profiles where key is the team id
    private static var remoteProvisioningProfiles: [String: [RemoteProvisioningProfile]] = [:]
    /// Dictionary of devices where key is the team id and value id of a device
    private static var devices: [String: [String]] = [:]
    /// Dictionary of certificates where key is the team id
    private static var certificates: [String: [RemoteCertificate]] = [:]
    /// Dictionary of bundle ids where key is the team id
    private static var bundleIds: [String: [RemoteBundleId]] = [:]
    
    private let signingFilesLocator: SigningFilesLocating
    private let rootDirectoryLocator: RootDirectoryLocating
    private let signingMatcher: SigningMatching
    private let signingInstaller: SigningInstalling
    private let signingLinter: SigningLinting
    private let securityController: SecurityControlling
    private let signingCipher: SigningCiphering
    private let appStoreConnectController: AppStoreConnectControlling
    private let apiKeyParser: APIKeyParsing

    public convenience init() {
        self.init(
            signingFilesLocator: SigningFilesLocator(),
            rootDirectoryLocator: RootDirectoryLocator(),
            signingMatcher: SigningMatcher(),
            signingInstaller: SigningInstaller(),
            signingLinter: SigningLinter(),
            securityController: SecurityController(),
            signingCipher: SigningCipher(),
            appStoreConnectController: AppStoreConnectController(),
            apiKeyParser: APIKeyParser()
        )
    }

    init(
        signingFilesLocator: SigningFilesLocating,
        rootDirectoryLocator: RootDirectoryLocating,
        signingMatcher: SigningMatching,
        signingInstaller: SigningInstalling,
        signingLinter: SigningLinting,
        securityController: SecurityControlling,
        signingCipher: SigningCiphering,
        appStoreConnectController: AppStoreConnectControlling,
        apiKeyParser: APIKeyParsing
    ) {
        self.signingFilesLocator = signingFilesLocator
        self.rootDirectoryLocator = rootDirectoryLocator
        self.signingMatcher = signingMatcher
        self.signingInstaller = signingInstaller
        self.signingLinter = signingLinter
        self.securityController = securityController
        self.signingCipher = signingCipher
        self.appStoreConnectController = appStoreConnectController
        self.apiKeyParser = apiKeyParser
    }

    public func vendor(graph: Graph) throws {
        let entryPath = graph.entryPath
        guard
            let signingDirectory = try signingFilesLocator.locateSigningDirectory(from: entryPath)
        else { return }

        try signingCipher.decryptSigning(at: entryPath, keepFiles: true)
        defer { try? signingCipher.encryptSigning(at: entryPath, keepFiles: false) }

        var (certificates, provisioningProfiles) = try signingMatcher.match(from: graph.entryPath)

        let apiKeys = Set(try signingFilesLocator.locateUnencryptedAPIKeys(from: entryPath))

        try graph.projects.forEach { project in
            try project.targets
                .flatMap { target in
                    target.signing.map { (target, $0) }
                }
                .forEach { target, signing in
                    let signingConfiguration: String
                    // TODO: Use to only download profiles with this team id (using conventional name for API key)
                    let signingTeamId: String
                    let signingType: SigningType
                    switch signing {
                    case let .development(teamId: teamId, configuration: configuration):
                        signingConfiguration = configuration
                        signingTeamId = teamId
                        signingType = .development
                    case let .distribution(teamId: teamId, configuration: configuration):
                        signingConfiguration = configuration
                        signingTeamId = teamId
                        signingType = .distribution
                    }
                    // TODO: Check if certificate is valid, too
                    if let provisioningProfile = provisioningProfiles[target.name]?[signingConfiguration] {
                        guard provisioningProfile.expirationDate < Date() else {
                            logger.debug("Skipping generating provisioning profile \(provisioningProfile.name) is valid.")
                            return
                        }
                    }

                    guard let apiKeyPath = apiKeys.first(where: { $0.basename.hasPrefix(signingTeamId) }) else {
                        logger.warning("Could not find api key for team id: \(signingTeamId). Make sure to download the API key from https://appstoreconnect.apple.com/access/api and rename it to TeamId.APIKeyId.IssuerId.p8")
                        return
                    }
                    let apiKey = try apiKeyParser.parse(at: apiKeyPath)

                    guard
                        try !remoteProvisioningProfiles(for: apiKey).contains(where: { $0.name == "\(target.name).\(signingConfiguration)" })
                    else { return }
                    
                    let deviceIds = try self.deviceIds(for: apiKey)
                    
                    let (mappedCertificates, certificate) = try map(
                        certificates,
                        targetName: target.name,
                        configurationName: signingConfiguration
                    )
                    certificates = mappedCertificates
                    
                    let certs = try self.certificates(for: apiKey)
                    
                    // TODO: Create bundle id if it does not exist
                    guard let bundleId = try bundleIds(for: apiKey).first(where: { $0.bundleId == target.bundleId }) else { return }
                    
                    let remoteProvisioningProfile = try appStoreConnectController.createProvisioningProfile(
                        for: apiKey,
                        id: bundleId.id,
                        name: "\(target.name).\(signingConfiguration)",
                        type: signingType,
                        certificateIds: ["9YNABA4MR3"],
                        deviceIds: deviceIds
                    )
                        .asSingle()
                        .toBlocking()
                        .single()
                    
                    
                    print(remoteProvisioningProfile)
                }
        }
    }
    
    public func install(graph: Graph) throws {
        let entryPath = graph.entryPath
        guard
            let signingDirectory = try signingFilesLocator.locateSigningDirectory(from: entryPath),
            let derivedDirectory = rootDirectoryLocator.locate(from: entryPath)?.appending(component: Constants.derivedFolderName)
        else { return }

        let keychainPath = derivedDirectory.appending(component: Constants.signingKeychain)

        let masterKey = try signingCipher.readMasterKey(at: signingDirectory)
        try FileHandler.shared.createFolder(derivedDirectory)
        if !FileHandler.shared.exists(keychainPath) {
            try securityController.createKeychain(at: keychainPath, password: masterKey)
        }
        try securityController.unlockKeychain(at: keychainPath, password: masterKey)
        defer { try? securityController.lockKeychain(at: keychainPath, password: masterKey) }

        try signingCipher.decryptSigning(at: entryPath, keepFiles: true)
        defer { try? signingCipher.encryptSigning(at: entryPath, keepFiles: false) }

        let (certificates, provisioningProfiles) = try signingMatcher.match(from: graph.entryPath)

        try graph.projects.forEach { project in
            try project.targets.forEach {
                try install(target: $0,
                            project: project,
                            keychainPath: keychainPath,
                            certificates: certificates,
                            provisioningProfiles: provisioningProfiles)
            }
        }
    }

    // MARK: - Helpers
    
    private func map(
        _ certificates: [String: [String: Certificate]],
        targetName: String,
        configurationName: String
        ) throws -> ([String: [String: Certificate]], Certificate) {
        if let certificate = certificates[targetName]?[configurationName],
            !certificate.isRevoked {
            return (certificates, certificate)
        } else {
//            let remoteCertificate: RemoteCertificate? = try self.certificates(for: apiKey).first(where: { certificate in
//                switch certificate.type {
//                case .development:
//                    return signingType == .development
//                case .distribution:
//                    return signingType == .distribution
//                }
//            })
            // TODO: Generate certificate and add it to dictionary
            fatalError()
        }
    }

    private func remoteProvisioningProfiles(for apiKey: APIKey) throws -> [RemoteProvisioningProfile] {
        if let remoteProvisioningProfiles = SigningInteractor.remoteProvisioningProfiles[apiKey.teamId] {
            return remoteProvisioningProfiles
        } else {
            let remoteProvisioningProfiles = try appStoreConnectController
                .provisioningProfiles(for: apiKey)
                .asSingle()
                .toBlocking()
                .single()
            SigningInteractor.remoteProvisioningProfiles[apiKey.teamId] = remoteProvisioningProfiles
            return remoteProvisioningProfiles
        }
    }
    
    private func deviceIds(for apiKey: APIKey) throws -> [String] {
        if let devices = SigningInteractor.devices[apiKey.teamId] {
            return devices
        } else {
            let devices = try appStoreConnectController
                .deviceIds(for: apiKey)
                .asSingle()
                .toBlocking()
                .single()
            SigningInteractor.devices[apiKey.teamId] = devices
            return devices
        }
    }
    
    private func certificates(for apiKey: APIKey) throws -> [RemoteCertificate] {
        if let certificates = SigningInteractor.certificates[apiKey.teamId] {
            return certificates
        } else {
            let certificates = try appStoreConnectController
                .certificates(for: apiKey)
                .asSingle()
                .toBlocking()
                .single()
            SigningInteractor.certificates[apiKey.teamId] = certificates
            return certificates
        }
    }
    
    private func bundleIds(for apiKey: APIKey) throws -> [RemoteBundleId] {
        if let bundleIds = SigningInteractor.bundleIds[apiKey.teamId] {
            return bundleIds
        } else {
            let bundleIds = try appStoreConnectController
                .bundleIds(for: apiKey)
                .asSingle()
                .toBlocking()
                .single()
            SigningInteractor.bundleIds[apiKey.teamId] = bundleIds
            return bundleIds
        }
    }

    private func install(target: Target,
                         project: Project,
                         keychainPath: AbsolutePath,
                         certificates: [TargetName: [ConfigurationName: Certificate]],
                         provisioningProfiles: [TargetName: [ConfigurationName: ProvisioningProfile]]) throws {
        let targetConfigurations = target.settings?.configurations ?? [:]
        /// Filtering certificate-provisioning profile pairs, so they are installed only when necessary (they correspond to some configuration and target in the project)
        let signingPairs = Set(
            targetConfigurations
                .merging(project.settings.configurations,
                         uniquingKeysWith: { config, _ in config })
                .keys
        )
        .compactMap { configuration -> (certificate: Certificate, provisioningProfile: ProvisioningProfile)? in
            guard
                let provisioningProfile = provisioningProfiles[target.name]?[configuration.name],
                let certificate = certificates[target.name]?[configuration.name]
            else {
                return nil
            }
            return (certificate: certificate, provisioningProfile: provisioningProfile)
        }

        try signingPairs.map(\.certificate).forEach {
            try signingInstaller.installCertificate($0, keychainPath: keychainPath)
        }
        try signingPairs.map(\.provisioningProfile).forEach(signingInstaller.installProvisioningProfile)
        try signingPairs.map(\.provisioningProfile).flatMap {
            signingLinter.lint(provisioningProfile: $0, target: target)
        }.printAndThrowIfNeeded()

        try signingPairs.flatMap(signingLinter.lint).printAndThrowIfNeeded()
        try signingPairs.map(\.certificate).flatMap(signingLinter.lint).printAndThrowIfNeeded()
    }
}
