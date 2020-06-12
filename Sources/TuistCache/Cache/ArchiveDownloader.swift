import Foundation
import RxSwift
import TSCBasic
import Zip

enum ArchiveDownloaderError: LocalizedError {
    case noLocalURL
    case invalidResponse
    case urlSessionError(Error)
    case moveFileError(Error)

    var errorDescription: String? {
        switch self {
        case .noLocalURL:
            return "Didn't receive a valid local URL"
        case .invalidResponse:
            return "Invalid URL response"
        case let .urlSessionError(error):
            if let error = error as? LocalizedError {
                return error.localizedDescription
            } else {
                return "Error while parsing the network response."
            }
        case let .moveFileError(error):
            if let error = error as? LocalizedError {
                return error.localizedDescription
            } else {
                return "Error while moving the network response."
            }
        }
    }
}

class ArchiveDownloader {
    private let urlSession: URLSession
    private let fileManager: FileManager

    init(urlSession: URLSession = URLSession.shared, fileManager: FileManager = FileManager.default) {
        self.urlSession = urlSession
        self.fileManager = fileManager
    }

    func download(url: URL, in directory: AbsolutePath) -> Single<AbsolutePath> {
        Single.create { observer -> Disposable in
            let task = self.urlSession.downloadTask(with: url) { localURL, response, networkError in
                if let networkError = networkError {
                    observer(.error(ArchiveDownloaderError.urlSessionError(networkError)))
                } else if let response = response as? HTTPURLResponse {
                    // Local URL
                    guard let localURL = localURL else {
                        observer(.error(ArchiveDownloaderError.noLocalURL))
                        return
                    }

                    self.processResponse(response, observer: observer, localURL: localURL, directory: directory)
                } else {
                    observer(.error(ArchiveDownloaderError.invalidResponse))
                }
            }

            task.resume()
            return Disposables.create { task.cancel() }
        }
    }

    // MARK: - Fileprivate

    private func processResponse(_ response: HTTPURLResponse,
                                 observer: (SingleEvent<AbsolutePath>) -> Void,
                                 localURL: URL,
                                 directory: AbsolutePath) {
        // HTTPURLResponse
        switch response.statusCode {
        case 200 ..< 300:
            // Success
            do {
                try Zip.unzipFile(localURL,
                                  destination: directory.asURL,
                                  overwrite: true,
                                  password: nil)
                observer(.success(directory))
            } catch {
                observer(.error(ArchiveDownloaderError.moveFileError(error)))
            }
        // Error
        default:
            observer(.error(ArchiveDownloaderError.invalidResponse))
        }
    }
}
