import Foundation

/// BigQuery error interface as documented here:
/// https://cloud.google.com/bigquery/docs/reference/rest/v2/ErrorProto
struct BigQueryErrorProto: Codable, CustomDebugStringConvertible, CustomStringConvertible {
    /// A short error code that summarizes the error.
    let reason: String

    /// Specifies where the error occurred, if present.
    let location: String

    /// Debugging information. This property is internal to Google and should not be used.
    let debugInfo: String

    /// A human-readable description of the error.
    let message: String

    enum CodingKeys: String, CodingKey {
        case reason
        case location
        case debugInfo
        case message
    }

    var description: String {
        message
    }

    var debugDescription: String {
        debugInfo
    }
}
