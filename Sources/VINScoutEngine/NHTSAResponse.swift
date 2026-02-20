import Foundation

// MARK: - Raw NHTSA API Response

/// Top-level response from the NHTSA vPIC DecodeVinValues endpoint.
/// Example endpoint: https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/[VIN]?format=json
public struct NHTSAResponse: Codable {
    /// The API always returns a single-element array under "Results".
    public let Results: [NHTSAResult]

    /// The API returns "SearchCriteria" at the top level (e.g., "VIN:1HGBH41JXMN109186").
    public let SearchCriteria: String?
}

/// A flat dictionary of vehicle attributes returned by the NHTSA API.
/// The API serializes all fields as a single flat object inside the Results array.
public struct NHTSAResult: Codable {

    // MARK: Error signaling fields
    /// Non-zero codes indicate warnings or errors from the API.
    /// "0" means success; "6" means "VIN corrected"; others indicate actual errors.
    public let ErrorCode: String?

    /// Human-readable description of any API-level error or warning.
    public let ErrorText: String?

    // MARK: Identity
    public let VIN: String?

    // MARK: Vehicle attributes
    public let ModelYear: String?
    public let Make: String?
    public let Model: String?
    public let Trim: String?
    public let BodyClass: String?
    public let DriveType: String?

    // MARK: Engine
    public let EngineCylinders: String?
    public let DisplacementL: String?
    public let FuelTypePrimary: String?
    public let EngineModel: String?

    // MARK: Additional useful fields
    public let Manufacturer: String?
    public let PlantCountry: String?
    public let VehicleType: String?

    // MARK: - Derived helpers

    /// Returns `true` when the API signals a genuine error (not just a warning/correction).
    /// ErrorCode "0" = Success, "6" = VIN corrected (acceptable), others = error.
    public var hasError: Bool {
        guard let code = ErrorCode, !code.isEmpty else { return false }
        // Multiple codes can be comma-separated, e.g. "6,11"
        let codes = code.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        // If all codes are 0 or 6 it's acceptable
        let fatalCodes = codes.filter { $0 != "0" && $0 != "6" }
        return !fatalCodes.isEmpty
    }

    /// Human-readable first non-empty error text segment.
    public var primaryErrorText: String? {
        guard let text = ErrorText, !text.isEmpty else { return nil }
        // ErrorText can also be comma-separated, return first segment
        return text.split(separator: ";").first.map { String($0).trimmingCharacters(in: .whitespaces) }
    }
}
