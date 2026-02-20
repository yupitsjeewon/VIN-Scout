import XCTest
@testable import VINScoutEngine

final class VINValidatorTests: XCTestCase {

    // MARK: - Valid VINs

    func test_validVIN_Honda() throws {
        // 2003 Honda Accord — verified check digit '3' at position 9
        XCTAssertNoThrow(try VINValidator.validate("1HGCM82633A004352"))
    }

    func test_validVIN_CheckDigitX() throws {
        // VIN where check digit is 'X' (i.e., remainder == 10)
        XCTAssertNoThrow(try VINValidator.validate("1M8GDM9AXKP042788"))
    }

    func test_validVIN_Numeric() throws {
        // VIN with digits only (where allowed)
        XCTAssertNoThrow(try VINValidator.validate("5YJSA1DG9DFP14705"))
    }

    // MARK: - Length Errors

    func test_tooShort_throws_invalidLength() {
        XCTAssertThrowsError(try VINValidator.validate("1HGBH41JXMN1091")) { error in
            XCTAssertEqual(error as? VINError, .invalidLength)
        }
    }

    func test_tooLong_throws_invalidLength() {
        XCTAssertThrowsError(try VINValidator.validate("1HGBH41JXMN109186XX")) { error in
            XCTAssertEqual(error as? VINError, .invalidLength)
        }
    }

    func test_empty_throws_invalidLength() {
        XCTAssertThrowsError(try VINValidator.validate("")) { error in
            XCTAssertEqual(error as? VINError, .invalidLength)
        }
    }

    // MARK: - Illegal Characters

    func test_containsI_throws_invalidCharacters() {
        // Position 4 is 'I'
        XCTAssertThrowsError(try VINValidator.validate("1HGIH41JXMN109186")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    func test_containsO_throws_invalidCharacters() {
        // Position 4 is 'O'
        XCTAssertThrowsError(try VINValidator.validate("1HGOH41JXMN109186")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    func test_containsQ_throws_invalidCharacters() {
        // Position 4 is 'Q'
        XCTAssertThrowsError(try VINValidator.validate("1HGQH41JXMN109186")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    func test_lowercase_throws_invalidCharacters() {
        XCTAssertThrowsError(try VINValidator.validate("1hgbh41jxmn109186")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    func test_specialCharacter_throws_invalidCharacters() {
        // Contains a space
        XCTAssertThrowsError(try VINValidator.validate("1HGBH41JXMN10918 ")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    func test_hyphen_throws_invalidCharacters() {
        XCTAssertThrowsError(try VINValidator.validate("1HGBH41JX-N109186")) { error in
            XCTAssertEqual(error as? VINError, .invalidCharacters)
        }
    }

    // MARK: - Check Digit (ISO 3779)

    func test_wrongCheckDigit_throws_invalidCheckDigit() {
        // Change check digit (position 9, index 8) from 'X' to '1'
        // "5YJSA1DG9DFP14705" is valid; changing 9→8 makes it invalid
        XCTAssertThrowsError(try VINValidator.validate("5YJSA1DG8DFP14705")) { error in
            XCTAssertEqual(error as? VINError, .invalidCheckDigit)
        }
    }

    func test_checkDigitXIsCorrect() throws {
        // VINs with X check digit must be accepted
        XCTAssertNoThrow(try VINValidator.validate("1M8GDM9AXKP042788"))
    }

    // MARK: - Edge Cases

    func test_allZeros_checkDigitIsActuallyValid() throws {
        // 00000000000000000: all positions are '0' (value 0), all weights ×0 produce sum=0.
        // 0 mod 11 = 0, and position 9 is also '0', so the check digit IS valid.
        // This documents the mathematical edge case — the validator should pass it.
        XCTAssertNoThrow(try VINValidator.validate("00000000000000000"))
    }
}
