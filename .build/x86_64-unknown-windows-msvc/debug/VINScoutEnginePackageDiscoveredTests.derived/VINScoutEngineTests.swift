import XCTest
@testable import VINScoutEngineTests

fileprivate extension HistoryManagerTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__HistoryManagerTests = [
        ("test_capsAtFive", test_capsAtFive),
        ("test_clear_removesAllHistory", test_clear_removesAllHistory),
        ("test_duplicateVIN_deduplicates", test_duplicateVIN_deduplicates),
        ("test_emptyHistory_returnsEmptyArray", test_emptyHistory_returnsEmptyArray),
        ("test_newestIsFirst", test_newestIsFirst),
        ("test_recordOne_appearsInHistory", test_recordOne_appearsInHistory)
    ]
}

fileprivate extension VINValidatorTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__VINValidatorTests = [
        ("test_allZeros_checkDigitIsActuallyValid", test_allZeros_checkDigitIsActuallyValid),
        ("test_checkDigitXIsCorrect", test_checkDigitXIsCorrect),
        ("test_containsI_throws_invalidCharacters", test_containsI_throws_invalidCharacters),
        ("test_containsO_throws_invalidCharacters", test_containsO_throws_invalidCharacters),
        ("test_containsQ_throws_invalidCharacters", test_containsQ_throws_invalidCharacters),
        ("test_empty_throws_invalidLength", test_empty_throws_invalidLength),
        ("test_hyphen_throws_invalidCharacters", test_hyphen_throws_invalidCharacters),
        ("test_lowercase_throws_invalidCharacters", test_lowercase_throws_invalidCharacters),
        ("test_specialCharacter_throws_invalidCharacters", test_specialCharacter_throws_invalidCharacters),
        ("test_tooLong_throws_invalidLength", test_tooLong_throws_invalidLength),
        ("test_tooShort_throws_invalidLength", test_tooShort_throws_invalidLength),
        ("test_validVIN_CheckDigitX", test_validVIN_CheckDigitX),
        ("test_validVIN_Honda", test_validVIN_Honda),
        ("test_validVIN_Numeric", test_validVIN_Numeric),
        ("test_wrongCheckDigit_throws_invalidCheckDigit", test_wrongCheckDigit_throws_invalidCheckDigit)
    ]
}

fileprivate extension VehicleMappingTests {
    @available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
    static nonisolated(unsafe) let __allTests__VehicleMappingTests = [
        ("test_decodeValidResponse_succeeds", test_decodeValidResponse_succeeds),
        ("test_hasError_false_forSuccessCode", test_hasError_false_forSuccessCode),
        ("test_hasError_true_forErrorCode11", test_hasError_true_forErrorCode11),
        ("test_primaryErrorText_isExtracted", test_primaryErrorText_isExtracted),
        ("test_searchCriteria_isCaptured", test_searchCriteria_isCaptured),
        ("test_vehicleMapping_bodyClass", test_vehicleMapping_bodyClass),
        ("test_vehicleMapping_driveType", test_vehicleMapping_driveType),
        ("test_vehicleMapping_emptyEngineCylinders_isNil", test_vehicleMapping_emptyEngineCylinders_isNil),
        ("test_vehicleMapping_fuelType", test_vehicleMapping_fuelType),
        ("test_vehicleMapping_make", test_vehicleMapping_make),
        ("test_vehicleMapping_manufacturer", test_vehicleMapping_manufacturer),
        ("test_vehicleMapping_model", test_vehicleMapping_model),
        ("test_vehicleMapping_trim", test_vehicleMapping_trim),
        ("test_vehicleMapping_vin_isUppercased", test_vehicleMapping_vin_isUppercased),
        ("test_vehicleMapping_year", test_vehicleMapping_year)
    ]
}
@available(*, deprecated, message: "Not actually deprecated. Marked as deprecated to allow inclusion of deprecated tests (which test deprecated functionality) without warnings")
func __VINScoutEngineTests__allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HistoryManagerTests.__allTests__HistoryManagerTests),
        testCase(VINValidatorTests.__allTests__VINValidatorTests),
        testCase(VehicleMappingTests.__allTests__VehicleMappingTests)
    ]
}