import AppStoreConnect_Swift_SDK
import Foundation
import RxSwift

struct RemoteBundleId {
    let id: String
    let bundleId: String
}

extension RemoteBundleId {
    init?(_ bundleId: BundleId) {
        id = bundleId.id
        guard let identifier = bundleId.attributes?.identifier else { return nil }
        self.bundleId = identifier
    }
}

struct RemoteProvisioningProfile {
    let name: String
    let profileContent: String
    let expirationDate: Date
}

extension RemoteProvisioningProfile {
    init?(_ profile: Profile) {
        guard
            let attributes = profile.attributes,
            let name = attributes.name,
            let profileContent = attributes.profileContent,
            let expirationDate = attributes.expirationDate
        else { return nil }

        self.name = name
        self.profileContent = profileContent
        self.expirationDate = expirationDate
    }
}

struct RemoteCertificate {
    enum CertificateType {
        case development
        case distribution
    }
    
    let id: String
    let type: CertificateType
}

extension RemoteCertificate {
    init?(_ certificate: AppStoreConnect_Swift_SDK.Certificate) {
        id = certificate.id
        guard let certificateType = certificate.attributes.certificateType else { return nil }
        switch certificateType {
        case .development:
            type = .development
        case .distribution:
            type = .distribution
        default:
            fatalError()
        }
    }
}

protocol AppStoreConnectControlling {
    func provisioningProfiles(for apiKey: APIKey) -> Observable<[RemoteProvisioningProfile]>
    func createProvisioningProfile(
        for apiKey: APIKey,
        id: String,
        name: String,
        type: SigningType,
        certificateIds: [String],
        deviceIds: [String]
    ) -> Observable<RemoteProvisioningProfile>
    func deviceIds(for apiKey: APIKey) -> Observable<[String]>
    func certificates(for apiKey: APIKey) -> Observable<[RemoteCertificate]>
    func bundleIds(for apiKey: APIKey) -> Observable<[RemoteBundleId]>
}


final class AppStoreConnectController: AppStoreConnectControlling {
    func provisioningProfiles(for apiKey: APIKey) -> Observable<[RemoteProvisioningProfile]> {
        let provider = APIProvider(apiKey)
        return provider.request(.listProfiles())
            .map { $0.data.compactMap(RemoteProvisioningProfile.init) }
    }
    
    func createProvisioningProfile(
        for apiKey: APIKey,
        id: String,
        name: String,
        type: SigningType,
        certificateIds: [String],
        deviceIds: [String]
    ) -> Observable<RemoteProvisioningProfile> {
        let provider = APIProvider(apiKey)
        let profileType: ProfileType
        switch type {
        case .development:
            profileType = .iOSAppDevelopment
        case .distribution:
            profileType = .iOSAppStore
        }
        return provider.request(
            .create(
                profileWithId: id,
                name: name,
                profileType: profileType,
                certificateIds: certificateIds,
                deviceIds: deviceIds
            )
        )
            .map(\.data)
            .compactMap(RemoteProvisioningProfile.init)
    }
    
    func deviceIds(for apiKey: APIKey) -> Observable<[String]> {
        let provider = APIProvider(apiKey)
        return provider.request(.listDevices())
            .map { $0.data.map(\.id) }
    }
    
    func certificates(for apiKey: APIKey) -> Observable<[RemoteCertificate]> {
        let provider = APIProvider(apiKey)
        return provider.request(.listDownloadCertificates())
            .map { $0.data.compactMap(RemoteCertificate.init) }
    }
    
    func bundleIds(for apiKey: APIKey) -> Observable<[RemoteBundleId]> {
        let provider = APIProvider(apiKey)
        return provider.request(.listBundleIds())
            .map { $0.data.compactMap(RemoteBundleId.init) }
    }
}

private extension APIProvider {
    convenience init(_ apiKey: APIKey) {
        let configuration = APIConfiguration(
            issuerID: apiKey.issuerId,
            privateKeyID: apiKey.apiKeyId,
            privateKey: apiKey.privateKey
        )
        self.init(configuration: configuration)
    }
}

private extension APIProvider {
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Observable<T> {
        Observable.create { observer in
            self.request(endpoint) { response in
                switch response {
                case let .success(response):
                    observer.onNext(response)
                case let .failure(error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
