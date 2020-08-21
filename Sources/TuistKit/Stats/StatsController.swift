import Foundation
import TuistSupport

public protocol StatsControlling {
    func report(event: StatsEvent)
    func report(event: StatsEvent, metadata: [AnyHashable: Any])
}

// https://cloud.google.com/bigquery/docs/reference/rest
public class StatsController: StatsControlling {
    public internal(set) static var shared: StatsControlling = StatsController()

    // MARK: - StatsControlling

    public func report(event: StatsEvent) {
        report(event: event, metadata: [:])
    }

    public func report(event _: StatsEvent, metadata _: [AnyHashable: Any]) {
        guard enabled else { return }
    }

    // MARK: - Private

    /// Returns true if stats are enabled.
    private var enabled: Bool {
        guard let variable = ProcessInfo.processInfo.environment[Constants.EnvironmentVariables.disableAnalytics] else {
            return true
        }
        return !Constants.trueValues.contains(variable)
    }
}
