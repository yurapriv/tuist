import Foundation
import RxSwift
import TSCBasic
import TuistCore
import TuistSupport

protocol BigQueryRowPersisting {
    /// Returns all the rows that are in the queue to be delivered.
    func readAll() -> Single<[BigQueryRow]>

    /// Persists a given row locally.
    /// - Parameter row: Row to be persisted.
    func write(_ row: BigQueryRow) -> Completable

    /// Deletes a given row from the local queue.
    /// - Parameter row: Row to be deleted.
    func delete(_ row: BigQueryRow) -> Completable
}

class BigQueryRowPersistor: BigQueryRowPersisting {
    private let directory: AbsolutePath

    init(directory: AbsolutePath = Environment.shared.statsDirectory) {
        self.directory = directory
    }

    func write(_ row: BigQueryRow) -> Completable {
        Completable.create { (observer) -> Disposable in
            do {
                let filePath = self.queueDirectory().appending(component: "\(row.fileName).json")
                let dictionary: [String: Any] = [
                    "table": row.table,
                    "data-set": row.dataSet,
                    "metadata": row.metadata,
                ]
                let content = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
                if !FileHandler.shared.exists(filePath.parentDirectory) {
                    try FileHandler.shared.createFolder(filePath.parentDirectory)
                }
                try content.write(to: filePath.url)
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }

    func readAll() -> Single<[BigQueryRow]> {
        let load: Observable<(loaded: [BigQueryRow], toDelete: [AbsolutePath])> = Observable.create { (observer) -> Disposable in
            var toDelete: [AbsolutePath] = []
            var loaded: [BigQueryRow] = []

            FileHandler.shared.glob(self.queueDirectory(), glob: "*.json").forEach { rowPath in
                do {
                    // If it's older than 1 days we delete the row
                    if let row = try self.loadRow(path: rowPath), Date().timeIntervalSince(row.date) < 60 * 60 * 24 * 1 {
                        loaded.append(row)
                    } else {
                        toDelete.append(rowPath)
                    }
                } catch {
                    toDelete.append(rowPath)
                }
            }

            observer.on(.next((loaded: loaded, toDelete: toDelete)))
            observer.onCompleted()
            return Disposables.create {}
        }

        return load.flatMapLatest { (loaded, toDelete) -> Observable<[BigQueryRow]> in
            let deleteObservables = toDelete.map(self.delete).map { $0.asObservable() }
            let deleteObservable = Observable.combineLatest(deleteObservables)

            // We delete the invalid ones and then return the loaded ones
            return deleteObservable.cast().concat(Observable<[BigQueryRow]>.just(loaded))
        }.asSingle()
    }

    func delete(_ row: BigQueryRow) -> Completable {
        delete(queueDirectory().appending(component: "\(row.fileName).json"))
    }

    // MARK: - Fileprivate

    fileprivate func loadRow(path: AbsolutePath) throws -> BigQueryRow? {
        let data = try FileHandler.shared.readFile(path)
        guard let dictionary = try (JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]) ?? [:],
            let table = dictionary["table"] as? String,
            let dataSet = dictionary["data-set"] as? String,
            let metadata = dictionary["metadata"] as? [AnyHashable: Any]
        else {
            return nil
        }

        let filename = path.basenameWithoutExt
        let (date, id) = try BigQueryRow.dateAndId(filename: filename)

        return BigQueryRow(table: table, dataSet: dataSet, id: id, date: date, metadata: metadata)
    }

    fileprivate func queueDirectory() -> AbsolutePath {
        directory.appending(component: "Queue")
    }

    fileprivate func delete(_ path: AbsolutePath) -> Completable {
        Completable.create { (observer) -> Disposable in
            do {
                if FileHandler.shared.exists(path) {
                    try FileHandler.shared.delete(path)
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
    }
}
