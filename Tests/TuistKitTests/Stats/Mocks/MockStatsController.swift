import Foundation
import TuistCore

public class MockStatsController: StatsControlling {
    var invokedReport = false
    var invokedReportCount = 0
    var invokedReportParameters: (event: StatsEvent, Void)?
    var invokedReportParametersList = [(event: StatsEvent, Void)]()

    func report(event: StatsEvent) {
        invokedReport = true
        invokedReportCount += 1
        invokedReportParameters = (event, ())
        invokedReportParametersList.append((event, ()))
    }

    var invokedReportEvent = false
    var invokedReportEventCount = 0
    var invokedReportEventParameters: (event: StatsEvent, metadata: [AnyHashable: Any])?
    var invokedReportEventParametersList = [(event: StatsEvent, metadata: [AnyHashable: Any])]()

    func report(event: StatsEvent, metadata: [AnyHashable: Any]) {
        invokedReportEvent = true
        invokedReportEventCount += 1
        invokedReportEventParameters = (event, metadata)
        invokedReportEventParametersList.append((event, metadata))
    }
}
