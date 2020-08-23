import Foundation
import RxSwift
import TuistSupport

protocol BigQueryDispatching {
    /// Pushes the a row to a table.
    /// - Parameters:
    ///   - row: Row to be pushed.
    func dispatch(row: BigQueryRow) -> Completable
}

class BigQueryDispatcher: BigQueryDispatching {
    // MARK: - Private

    private let httpRequestDispatcher: HTTPRequestDispatching

    // MARK: - Init

    init(httpRequestDispatcher: HTTPRequestDispatching = HTTPRequestDispatcher()) {
        self.httpRequestDispatcher = httpRequestDispatcher
    }

    // MARK: - BigQueryDispatching

    func dispatch(row _: BigQueryRow) -> Completable {
        Completable.create { (observer) -> Disposable in
            // TODO:
            // https://bigquery.googleapis.com
            // https://cloud.google.com/bigquery/docs/reference/rest/v2/tabledata/insertAll
            observer(.completed)
            return Disposables.create {}
        }
    }
}
