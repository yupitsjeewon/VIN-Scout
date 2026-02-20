import Foundation

/// Client-side VIN validation per ISO 3779 / SAE J853 standards.
///
/// Catches invalid VINs before making any network call, including:
/// - Wrong length
/// - Illegal characters (I, O, Q) or non-alphanumeric
/// - ISO 3779 check digit failures (position 9)
public enum VINValidator {

    // MARK: - Public API

    /// Validates a VIN string.
    ///
    /// - Parameter vin: The VIN to validate. Must be 17 uppercase alphanumeric characters,
    ///   excluding I, O, and Q.
    /// - Throws: `VINError.invalidLength`, `VINError.invalidCharacters`,
    ///   or `VINError.invalidCheckDigit`.
    public static func validate(_ vin: String) throws {
        // Rule 1: Must be exactly 17 characters
        guard vin.count == 17 else {
            throw VINError.invalidLength
        }

        // Rule 2: Must be uppercase and use only valid VIN characters [A-HJ-NPR-Z0-9]
        // This automatically excludes I, O, Q and any lowercase letters.
        let validCharset = CharacterSet(charactersIn: "ABCDEFGHJKLMNPRSTUVWXYZ0123456789")
        guard vin.unicodeScalars.allSatisfy({ validCharset.contains($0) }) else {
            throw VINError.invalidCharacters
        }

        // Rule 3: ISO 3779 check digit verification (position index 8, the 9th character)
        let computed = try computeCheckDigit(vin)
        let actual = String(vin[vin.index(vin.startIndex, offsetBy: 8)])
        guard computed == actual else {
            throw VINError.invalidCheckDigit
        }
    }

    // MARK: - ISO 3779 Check Digit Algorithm

    /// Computes the ISO 3779 check digit for the given VIN.
    ///
    /// The algorithm:
    /// 1. Transliterate each character to a numeric value using a lookup table.
    /// 2. Multiply each value by its positional weight.
    /// 3. Sum all products.
    /// 4. Take the sum modulo 11.
    /// 5. Map result: 10 → "X", else the digit as a String.
    ///
    /// - Parameter vin: A 17-character VIN (pre-validated for length and charset).
    /// - Returns: The expected check digit character ("0"–"9" or "X").
    private static func computeCheckDigit(_ vin: String) throws -> String {
        var sum = 0
        let chars = Array(vin)

        for (index, char) in chars.enumerated() {
            guard let value = transliterationValue(for: char) else {
                throw VINError.invalidCharacters
            }
            sum += value * positionWeight(for: index)
        }

        let remainder = sum % 11
        return remainder == 10 ? "X" : "\(remainder)"
    }

    // MARK: - Lookup Tables

    /// ISO 3779 transliteration table: maps each valid VIN character to an integer value.
    private static func transliterationValue(for char: Character) -> Int? {
        let table: [Character: Int] = [
            "A": 1,  "B": 2,  "C": 3,  "D": 4,  "E": 5,
            "F": 6,  "G": 7,  "H": 8,
            // I is excluded from valid VINs
            "J": 1,  "K": 2,  "L": 3,  "M": 4,  "N": 5,
            // O is excluded from valid VINs
            "P": 7,
            // Q is excluded from valid VINs
            "R": 9,
            "S": 2,  "T": 3,  "U": 4,  "V": 5,  "W": 6,  "X": 7,  "Y": 8,  "Z": 9,
            "0": 0,  "1": 1,  "2": 2,  "3": 3,  "4": 4,
            "5": 5,  "6": 6,  "7": 7,  "8": 8,  "9": 9
        ]
        return table[char]
    }

    /// ISO 3779 positional weights for VIN positions 1–17 (index 0–16).
    private static func positionWeight(for index: Int) -> Int {
        let weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
        // Position 9 (index 8) has weight 0 because it IS the check digit position.
        guard index < weights.count else { return 0 }
        return weights[index]
    }
}
