import Foundation

/// All errors that can be thrown by the VINScoutEngine.
public enum VINError: Error, LocalizedError, Equatable {

    // MARK: - Validation Errors
    /// The VIN is not exactly 17 characters long.
    case invalidLength

    /// The VIN contains illegal characters (I, O, Q) or non-alphanumeric characters,
    /// or was not supplied in uppercase.
    case invalidCharacters

    /// The ISO 3779 check digit (position 9) does not match the computed value.
    case invalidCheckDigit

    // MARK: - Network Errors
    /// A network-level failure occurred (e.g. no connectivity, DNS failure).
    case networkIssue(String)

    /// The request timed out before a response was received.
    case timeout

    // MARK: - API / Decoding Errors
    /// The NHTSA API returned a 200 OK but the body contained an error description.
    case apiError(String)

    /// The response body could not be decoded into the expected model.
    case decodingError(String)

    // MARK: - LocalizedError
    public var errorDescription: String? {
        switch self {
        case .invalidLength:
            return "A VIN must be exactly 17 characters long."
        case .invalidCharacters:
            return "A VIN may only contain uppercase letters and digits, excluding I, O, and Q."
        case .invalidCheckDigit:
            return "The VIN check digit is invalid. Please verify you entered the VIN correctly."
        case .networkIssue(let detail):
            return "A network error occurred: \(detail)"
        case .timeout:
            return "The request timed out. Please check your internet connection and try again."
        case .apiError(let text):
            return "The NHTSA API reported an error: \(text)"
        case .decodingError(let detail):
            return "Failed to decode the server response: \(detail)"
        }
    }

    // MARK: - Equatable
    // Custom conformance because associated values differ in type.
    public static func == (lhs: VINError, rhs: VINError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidLength, .invalidLength): return true
        case (.invalidCharacters, .invalidCharacters): return true
        case (.invalidCheckDigit, .invalidCheckDigit): return true
        case (.timeout, .timeout): return true
        case (.networkIssue(let a), .networkIssue(let b)): return a == b
        case (.apiError(let a), .apiError(let b)): return a == b
        case (.decodingError(let a), .decodingError(let b)): return a == b
        default: return false
        }
    }
}
