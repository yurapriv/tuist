import Foundation
import TuistSupport

public protocol StatsControlling {
    func startFlushing()
    func report(event: StatsEventName)
    func report(event: StatsEventName, metadata: [AnyHashable: Any])
}

// https://cloud.google.com/bigquery/docs/reference/rest
public class StatsController: StatsControlling {
    public internal(set) static var shared: StatsControlling = StatsController()

    private let bigQueryController: BigQueryControlling

    // MARK: - Init

    convenience init() {
        self.init(bigQueryController: BigQueryController())
    }

    init(bigQueryController: BigQueryControlling) {
        self.bigQueryController = bigQueryController
    }

    // MARK: - StatsControlling

    public func report(event: StatsEventName) {
        report(event: event, metadata: [:])
    }

    public func report(event: StatsEventName, metadata: [AnyHashable: Any]) {
        guard enabled else { return }
        bigQueryController.report(event: event, metadata: metadata)
    }

    public func startFlushing() {
        bigQueryController.startFlushing()
    }

    // MARK: - Private

    /// Returns true if stats are enabled.
    private var enabled: Bool {
        guard let variable = ProcessInfo.processInfo.environment[Constants.EnvironmentVariables.disableStats] else {
            return true
        }
        return !Constants.trueValues.contains(variable)
    }
}
