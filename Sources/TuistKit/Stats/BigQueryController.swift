import Foundation
import RxBlocking
import RxSwift
import TuistSupport

protocol BigQueryControlling {
    /// Start flushing all the events.
    func startFlushing()

    /// Report an event to big query.
    /// - Parameters:
    ///   - event: Event name.
    ///   - metadata: Event metadata.
    func report(event: StatsEventName, metadata: [AnyHashable: Any])
}

class BigQueryController: BigQueryControlling {
    private static let dataset: String = "tuist-243221:stats"
    private static let eventsTable: String = "events"

    private let dispatchQueue: () -> DispatchQueue
    private let bigQueryRowPersistor: BigQueryRowPersisting
    private let bigQueryDispatcher: BigQueryDispatching
    private var runningOperations: [UUID: Completable] = [:]
    private let runningOperationsLock = NSLock()

    init(dispatchQueue: @escaping () -> DispatchQueue = { DispatchQueue(label: "io.tuist.stats", qos: .background) },
         bigQueryRowPersistor: BigQueryRowPersisting = BigQueryRowPersistor(),
         bigQueryDispatcher: BigQueryDispatching = BigQueryDispatcher())
    {
        self.dispatchQueue = dispatchQueue
        self.bigQueryRowPersistor = bigQueryRowPersistor
        self.bigQueryDispatcher = bigQueryDispatcher
    }

    // MARK: - BigQueryControlling

    func report(event: StatsEventName, metadata: [AnyHashable: Any]) {
        var metadata = metadata
        metadata["name"] = event.rawValue
        let row = BigQueryRow(table: BigQueryController.eventsTable,
                              dataSet: BigQueryController.dataset,
                              metadata: metadata)
        dispatch(row: row, store: true)
    }

    func startFlushing() {
        _ = bigQueryRowPersistor.readAll()
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: dispatchQueue()))
            .subscribe { rows in
                switch rows {
                case let .success(rows):
                    rows.forEach { row in
                        self.dispatch(row: row, store: false)
                    }
                case .error:
                    return
                }
            }
    }

    // MARK: - Private

    private func dispatch(row: BigQueryRow, store: Bool) {
        if isRunning(id: row.id) { return }

        let persist = bigQueryRowPersistor.write(row)
        let send = bigQueryDispatcher.dispatch(row: row)
        let removeRunningOperation = Completable.create { (_) -> Disposable in
            self.removeRunningOperation(id: row.id)
            return Disposables.create {}
        }
        let delete = bigQueryRowPersistor.delete(row).concat(removeRunningOperation)

        if store {
            // We need to block the process.
            // Otherwise, the main process might exist and the row hasn't been persisted.
            _ = try? persist.toBlocking().last()
        }

        let completable = send
            .runOnErrorOrCompletion(delete)
            .subscribeOn(ConcurrentDispatchQueueScheduler(queue: dispatchQueue()))
        addRunningOperation(id: row.id, completable: completable)
    }

    private func isRunning(id: UUID) -> Bool {
        runningOperationsLock.lock()
        defer { runningOperationsLock.unlock() }
        return runningOperations[id] != nil
    }

    private func addRunningOperation(id: UUID, completable: Completable) {
        runningOperationsLock.lock()
        defer { runningOperationsLock.unlock() }
        runningOperations[id] = completable
        _ = completable.subscribe()
    }

    private func removeRunningOperation(id: UUID) {
        runningOperationsLock.lock()
        defer { runningOperationsLock.unlock() }
        runningOperations.removeValue(forKey: id)
    }
}
