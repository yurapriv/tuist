import Foundation

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

    public func report(event _: StatsEvent, metadata _: [AnyHashable: Any]) {}
}
