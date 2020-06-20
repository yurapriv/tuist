import AppStoreConnect_Swift_SDK
import Foundation
import RxSwift

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

protocol AppStoreConnectControlling {
    func provisioningProfiles(for apiKey: APIKey) -> Observable<[RemoteProvisioningProfile]>
}

final class AppStoreConnectController: AppStoreConnectControlling {
    func provisioningProfiles(for apiKey: APIKey) -> Observable<[RemoteProvisioningProfile]> {
        let provider = APIProvider(apiKey)
        return provider.request(.listProfiles()).map { $0.data.compactMap(RemoteProvisioningProfile.init) }
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
