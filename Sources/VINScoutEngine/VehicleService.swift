import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Fetches and decodes vehicle data from the NHTSA vPIC API.
///
/// # Usage
/// ```swift
/// let service = VehicleService()
/// let vehicle = try await service.lookup(vin: "1HGBH41JXMN109186")
/// ```
///
/// # Dependency Injection (Testing)
/// ```swift
/// let service = VehicleService(httpClient: MockHTTPClient())
/// ```
public final class VehicleService: Sendable {

    // MARK: - Constants
    private static let baseURL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues"
    private static let timeoutInterval: TimeInterval = 15

    // MARK: - Dependencies
    private let httpClient: HTTPClient

    // MARK: - Init
    /// Creates a new `VehicleService`.
    /// - Parameter httpClient: An `HTTPClient` conformer. Defaults to a shared
    ///   `URLSession` configured with a 15-second timeout.
    public init(httpClient: HTTPClient? = nil) {
        if let client = httpClient {
            self.httpClient = client
        } else {
            // URLSessionHTTPClient bridges completion-handler URLSession APIs
            // to async/await on Windows/Linux (FoundationNetworking).
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = VehicleService.timeoutInterval
            config.timeoutIntervalForResource = VehicleService.timeoutInterval
            self.httpClient = URLSessionHTTPClient(session: URLSession(configuration: config))
        }
    }

    // MARK: - Public API

    /// Looks up a vehicle by VIN. Validates the VIN locally before making a network call.
    ///
    /// - Parameter vin: The 17-character Vehicle Identification Number (uppercase).
    /// - Returns: A fully populated `Vehicle` model.
    /// - Throws: `VINError` for validation failures, network issues, or API errors.
    public func lookup(vin: String) async throws -> Vehicle {
        // 1. Client-side validation first (saves a network round-trip)
        try VINValidator.validate(vin)

        // 2. Build URL
        guard let url = URL(string: "\(VehicleService.baseURL)/\(vin)?format=json") else {
            throw VINError.networkIssue("Could not construct a valid URL for VIN: \(vin)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = VehicleService.timeoutInterval

        // 3. Execute request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await httpClient.data(for: request)
        } catch let urlError as URLError {
            if urlError.code == .timedOut {
                throw VINError.timeout
            }
            throw VINError.networkIssue(urlError.localizedDescription)
        } catch {
            throw VINError.networkIssue(error.localizedDescription)
        }

        // 4. HTTP status check
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            throw VINError.networkIssue("Unexpected HTTP status code: \(httpResponse.statusCode)")
        }

        // 5. Decode JSON
        let decoded: NHTSAResponse
        do {
            let decoder = JSONDecoder()
            decoded = try decoder.decode(NHTSAResponse.self, from: data)
        } catch {
            throw VINError.decodingError(error.localizedDescription)
        }

        // 6. Extract the first result
        guard let result = decoded.Results.first else {
            throw VINError.decodingError("Response contained an empty 'Results' array.")
        }

        // 7. NHTSA-specific error handling:
        //    The API returns 200 OK even for invalid VINs — inspect body error fields.
        if result.hasError {
            let text = result.primaryErrorText ?? "Unknown API error (ErrorCode: \(result.ErrorCode ?? "?"))"
            throw VINError.apiError(text)
        }

        // 8. Map to clean internal model
        return Vehicle.from(vin: vin, result: result)
    }
}
