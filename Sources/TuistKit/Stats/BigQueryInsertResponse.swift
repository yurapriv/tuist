import Foundation
import TuistSupport

/// It represents the response from BigQuery's REST API endpoint for inserting rows.
/// The response is documented here: https://cloud.google.com/bigquery/docs/reference/rest/v2/tabledata/insertAll#response-body
struct BigQueryInsertResponse: Codable, Error {
    struct Error: Codable, CustomStringConvertible {
        let index: UInt32
        let errors: [BigQueryErrorProto]

        var description: String {
            errors.map(\.description).joined(separator: "\n")
        }
    }

    // MARK: - Attributes

    let kind: String
    let insertErrors: [BigQueryInsertResponse.Error]

    // MARK: - Resources

    // POST https://bigquery.googleapis.com/bigquery/v2/projects/{projectId}/datasets/{datasetId}/tables/{tableId}/insertAll
    static func insertAll(projectId: String,
                          datasetId: String,
                          tableId: String,
                          skipInvalidRows: Bool? = nil,
                          ignoreUnknownValues: Bool? = nil,
                          templateSuffix: String? = nil,
                          rows: [[AnyHashable: Any]]) -> HTTPResource<BigQueryInsertResponse, BigQueryInsertResponse>
    {
        .jsonResource(request: {
            // Request structure
            var urlComponents = URLComponents(url: Constants.GoogleBigQuery.apiBaseURL, resolvingAgainstBaseURL: false)!
            urlComponents.path = "/bigquery/v2/projects/\(projectId)/datasets/\(datasetId)/tables/\(tableId)/insertAll"
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "POST"

            // Request body
            var body: [String: Any] = [:]
            if let skipInvalidRows = skipInvalidRows {
                body["skipInvalidRows"] = skipInvalidRows
            }
            if let ignoreUnknownValues = ignoreUnknownValues {
                body["ignoreUnknownValues"] = ignoreUnknownValues
            }
            if let templateSuffix = templateSuffix {
                body["templateSuffix"] = templateSuffix
            }
            body["rows"] = rows.map { ["json": $0] }

            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
            return request
        })
    }
}
