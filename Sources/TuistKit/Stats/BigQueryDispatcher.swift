import Foundation
import RxSwift

protocol BigQueryDispatching {
    /// Pushes the a row to a table.
    /// - Parameters:
    ///   - row: Row to be pushed.
    func dispatch(row: BigQueryRow) -> Completable
}

class BigQueryDispatcher: BigQueryDispatching {
    init() {}

    // MARK: - BigQueryDispatching

    func dispatch(row _: BigQueryRow) -> Completable {
        Completable.create { (observer) -> Disposable in
            // TODO:
            observer(.completed)
            return Disposables.create {}
        }
    }
}
