import AppStoreConnect_Swift_SDK
import RxSwift

// TODO: Remove public

protocol AppStoreConnectControlling {
    func provisioningProfiles() -> Observable<ProfilesResponse>
}

final class AppStoreConnectController: AppStoreConnectControlling {
    let configuration = APIConfiguration(
        issuerID: "69a6de83-c998-47e3-e053-5b8c7c11a4d1",
        privateKeyID: "R62H997UGZ",
        privateKey: "MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg3OeXP6j7QjPOufTZUXR0TzzupYSLHQMWEh43xWWWGQagCgYIKoZIzj0DAQehRANCAARJ1aHt+ZIiqpMEg/RkkeRldzNhJMMQWALd9plXFNA4Qd+nr/g+wGYSjJ86AU4rwLEJ1Cj4ElU9j5jeNCNZbOY7"
    )
    
    func provisioningProfiles() -> Observable<ProfilesResponse> {
        let provider: APIProvider = APIProvider(configuration: configuration)
        return provider.request(.listProfiles()).map {
            $0
        }
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
