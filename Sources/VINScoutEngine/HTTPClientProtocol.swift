import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Abstracts the HTTP transport layer so `VehicleService` can be tested
/// with a mock without spinning up a real network connection.
public protocol HTTPClient: Sendable {
    /// Performs an HTTP request and returns the raw data and response.
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// MARK: - URLSessionHTTPClient
// On Apple platforms URLSession has native async/await support.
// On Windows/Linux (FoundationNetworking), only completion-handler APIs exist,
// so we wrap the session in a concrete type and bridge with a continuation.

public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
#if canImport(FoundationNetworking)
        // Windows/Linux: bridge completion handler → async/await
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            task.resume()
        }
#else
        // Apple platforms: use the native async API
        return try await session.data(for: request)
#endif
    }
}
