import XCTest
@testable import VINScoutEngine

final class HistoryManagerTests: XCTestCase {

    // MARK: - Helpers

    private func makeManager() -> HistoryManager {
        HistoryManager(store: InMemoryPersistence())
    }

    private func makeVehicle(vin: String, make: String = "HONDA") -> Vehicle {
        Vehicle(
            vin: vin,
            year: "2022",
            make: make,
            model: "Civic",
            trim: nil,
            bodyClass: "Sedan",
            driveType: "FWD",
            engineCylinders: "4",
            engineDisplacementL: "1.5",
            fuelType: "Gasoline",
            manufacturer: make,
            plantCountry: "USA",
            vehicleType: "PASSENGER CAR"
        )
    }

    // MARK: - Tests

    func test_emptyHistory_returnsEmptyArray() {
        let manager = makeManager()
        XCTAssertTrue(manager.history().isEmpty)
    }

    func test_recordOne_appearsInHistory() {
        let manager = makeManager()
        let v = makeVehicle(vin: "1HGCB7659NA057340")
        manager.record(v)
        XCTAssertEqual(manager.history().count, 1)
        XCTAssertEqual(manager.history().first?.vin, "1HGCB7659NA057340")
    }

    func test_newestIsFirst() {
        let manager = makeManager()
        manager.record(makeVehicle(vin: "1HGCB7659NA057340"))
        manager.record(makeVehicle(vin: "5YJ3E1EA4NF306255", make: "TESLA"))
        XCTAssertEqual(manager.history().first?.vin, "5YJ3E1EA4NF306255")
    }

    func test_capsAtFive() {
        let manager = makeManager()
        let vins = [
            "1HGCB7659NA057340",
            "5YJ3E1EA4NF306255",
            "1M8GDM9AXKP042788",
            "WVGZZZ5NZAM027928",
            "JH4KA3150HC006949",
            "1FAHP3K27CL333349"   // 6th — should push out the oldest
        ]
        for vin in vins {
            manager.record(makeVehicle(vin: vin))
        }
        XCTAssertEqual(manager.history().count, 5)
        // Most recent should be first
        XCTAssertEqual(manager.history().first?.vin, "1FAHP3K27CL333349")
        // Oldest (first recorded) should be gone
        XCTAssertFalse(manager.history().contains { $0.vin == "1HGCB7659NA057340" })
    }

    func test_duplicateVIN_deduplicates() {
        let manager = makeManager()
        let v1 = makeVehicle(vin: "1HGCB7659NA057340")
        let v2 = makeVehicle(vin: "5YJ3E1EA4NF306255")
        manager.record(v1)
        manager.record(v2)
        manager.record(v1) // Record v1 again — should move to top, not duplicate
        XCTAssertEqual(manager.history().count, 2)
        XCTAssertEqual(manager.history().first?.vin, "1HGCB7659NA057340")
    }

    func test_clear_removesAllHistory() {
        let manager = makeManager()
        manager.record(makeVehicle(vin: "1HGCB7659NA057340"))
        manager.record(makeVehicle(vin: "5YJ3E1EA4NF306255"))
        manager.clear()
        XCTAssertTrue(manager.history().isEmpty)
    }
}
