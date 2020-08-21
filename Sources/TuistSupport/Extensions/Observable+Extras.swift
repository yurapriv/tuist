import Foundation
import RxSwift

public extension Observable {
    func cast<T>() -> Observable<T> {
        ignoreElements().asObservable().compactMap { _ in nil }
    }
}
