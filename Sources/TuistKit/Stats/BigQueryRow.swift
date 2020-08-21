import Foundation
import TuistSupport

enum BigQueryRowError: FatalError {
    case invalidName(String)
    case invalidTimestamp(String)
    case invalidUUID(String)

    var type: ErrorType {
        switch self {
        case .invalidName: return .abort
        case .invalidTimestamp: return .abort
        case .invalidUUID: return .abort
        }
    }

    var description: String {
        switch self {
        case let .invalidName(name):
            return "Unexpected file name for big query row: '\(name)'. It should be {timestamp}-{id}."
        case let .invalidTimestamp(timestamp):
            return "The string '\(timestamp)' is not a valid UNIX timestamp."
        case let .invalidUUID(timestamp):
            return "The string '\(timestamp)' is not a valid UUID."
        }
    }
}

struct BigQueryRow: Identifiable {
    let id: UUID
    let date: Date
    let table: String
    let dataSet: String
    let metadata: [AnyHashable: Any]

    enum CodingKeys: CodingKey {
        case id
        case date
        case metadata
    }

    init(table: String,
         dataSet: String,
         id: UUID = .init(),
         date: Date = .init(),
         metadata: [AnyHashable: Any])
    {
        self.table = table
        self.dataSet = dataSet
        self.id = id
        self.date = date
        self.metadata = metadata
    }

    /// The name of the file to persist the row locally.
    var fileName: String {
        "\(date.timeIntervalSince1970).\(id)"
    }

    static func dateAndId(filename: String) throws -> (Date, UUID) {
        let components = filename.split(separator: ".")
        guard components.count == 2 else {
            throw BigQueryRowError.invalidName(filename)
        }
        guard let timestamp = TimeInterval(components.first!) else {
            throw BigQueryRowError.invalidTimestamp(String(components.first!))
        }
        guard let uuid = UUID(uuidString: String(components.last!)) else {
            throw BigQueryRowError.invalidUUID(String(components.last!))
        }

        let date = Date(timeIntervalSince1970: timestamp)
        return (date, uuid)
    }
}
