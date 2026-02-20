import XCTest
@testable import VINScoutEngine

final class VehicleMappingTests: XCTestCase {

    // MARK: - Mock JSON
    // A representative response from the NHTSA DecodeVinValues endpoint
    // for a 2022 Tesla Model 3 (VIN: 5YJ3E1EA4NF306255).
    private let mockJSON = """
    {
        "Count": 1,
        "Message": "Results returned successfully",
        "SearchCriteria": "VIN:5YJ3E1EA4NF306255",
        "Results": [
            {
                "ABS": "",
                "BodyClass": "Sedan/Saloon",
                "DisplacementL": "",
                "DriveType": "Rear-Wheel Drive",
                "EngineCylinders": "",
                "EngineModel": "Electric",
                "ErrorCode": "0",
                "ErrorText": "0 - VIN decoded clean. Check Digit (9th position) is correct",
                "FuelTypePrimary": "Electric",
                "Make": "TESLA",
                "Manufacturer": "TESLA, INC.",
                "Model": "Model 3",
                "ModelYear": "2022",
                "PlantCountry": "UNITED STATES (USA)",
                "Trim": "Standard Range Plus",
                "VehicleType": "PASSENGER CAR",
                "VIN": "5YJ3E1EA4NF306255"
            }
        ]
    }
    """

    private let mockAPIErrorJSON = """
    {
        "Count": 1,
        "Message": "Results returned successfully",
        "SearchCriteria": "VIN:ZZZZZZZZZZZZZZZZ",
        "Results": [
            {
                "ErrorCode": "11",
                "ErrorText": "11 - Incorrect Model Year (Decoded Year is inconsistent with the model year in the VIN)",
                "Make": "",
                "Manufacturer": "",
                "Model": "",
                "ModelYear": "",
                "VIN": "ZZZZZZZZZZZZZZZZ",
                "BodyClass": "",
                "DriveType": "",
                "EngineCylinders": "",
                "DisplacementL": "",
                "FuelTypePrimary": "",
                "EngineModel": "",
                "PlantCountry": "",
                "Trim": "",
                "VehicleType": ""
            }
        ]
    }
    """

    // MARK: - Decoding Tests

    func test_decodeValidResponse_succeeds() throws {
        let data = Data(mockJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        XCTAssertEqual(response.Results.count, 1)
    }

    func test_searchCriteria_isCaptured() throws {
        let data = Data(mockJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        XCTAssertEqual(response.SearchCriteria, "VIN:5YJ3E1EA4NF306255")
    }

    // MARK: - Vehicle Mapping Tests

    func test_vehicleMapping_year() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.year, "2022")
    }

    func test_vehicleMapping_make() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.make, "TESLA")
    }

    func test_vehicleMapping_model() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.model, "Model 3")
    }

    func test_vehicleMapping_trim() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.trim, "Standard Range Plus")
    }

    func test_vehicleMapping_bodyClass() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.bodyClass, "Sedan/Saloon")
    }

    func test_vehicleMapping_driveType() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.driveType, "Rear-Wheel Drive")
    }

    func test_vehicleMapping_fuelType() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.fuelType, "Electric")
    }

    func test_vehicleMapping_manufacturer() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.manufacturer, "TESLA, INC.")
    }

    func test_vehicleMapping_emptyEngineCylinders_isNil() throws {
        // Tesla returns empty string for cylinders → should map to nil
        let vehicle = try decodedVehicle()
        XCTAssertNil(vehicle.engineCylinders)
    }

    func test_vehicleMapping_vin_isUppercased() throws {
        let vehicle = try decodedVehicle()
        XCTAssertEqual(vehicle.vin, "5YJ3E1EA4NF306255")
    }

    // MARK: - Error Detection Tests

    func test_hasError_false_forSuccessCode() throws {
        let data = Data(mockJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        XCTAssertFalse(response.Results.first!.hasError)
    }

    func test_hasError_true_forErrorCode11() throws {
        let data = Data(mockAPIErrorJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        XCTAssertTrue(response.Results.first!.hasError)
    }

    func test_primaryErrorText_isExtracted() throws {
        let data = Data(mockAPIErrorJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        let errorText = response.Results.first?.primaryErrorText
        XCTAssertNotNil(errorText)
        XCTAssertTrue(errorText?.contains("Incorrect Model Year") == true)
    }

    // MARK: - Helpers

    private func decodedVehicle() throws -> Vehicle {
        let data = Data(mockJSON.utf8)
        let response = try JSONDecoder().decode(NHTSAResponse.self, from: data)
        let result = try XCTUnwrap(response.Results.first)
        return Vehicle.from(vin: "5YJ3E1EA4NF306255", result: result)
    }
}
