import Foundation
import RxSwift

public extension Completable {
    func runOnErrorOrCompletion(_ completable: Completable) -> Completable {
        catchError { error in
            completable.concat(Completable.error(error))
        }.concat(completable)
    }
}
