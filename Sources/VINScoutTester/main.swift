import Foundation
import VINScoutEngine

// MARK: - VINScoutTester
// A command-line tool to exercise the VINScoutEngine on Windows.
//
// Usage:
//   swift run VINScoutTester <VIN>
//   swift run VINScoutTester <VIN> --history   (show lookup history after)
//
// Examples:
//   swift run VINScoutTester 5YJ3E1EA4NF306255
//   swift run VINScoutTester INVALID

// MARK: - Parse Arguments
let args = CommandLine.arguments

guard args.count >= 2 else {
    fputs("""
    ╔══════════════════════════════════════╗
    ║           VIN Scout Tester           ║
    ╚══════════════════════════════════════╝
    
    Usage:  swift run VINScoutTester <VIN> [--history]
    
    Examples:
      swift run VINScoutTester 5YJ3E1EA4NF306255
      swift run VINScoutTester 1HGCB7659NA057340 --history
      swift run VINScoutTester BADVIN
    
    """, stderr)
    exit(1)
}

let vin = args[1].uppercased()
let showHistory = args.contains("--history")

// MARK: - Shared History Manager (in-memory for this session)
let historyManager = HistoryManager(store: InMemoryPersistence())

// MARK: - Banner
print("""
╔══════════════════════════════════════╗
║           VIN Scout Tester           ║
╚══════════════════════════════════════╝
""")
print("🔍 Looking up VIN: \(vin)")
print("")

// MARK: - Async Entry Point
// We use a Task + semaphore pattern so this works on Windows where
// @main + async is unavailable without the Swift Concurrency runtime shim.
let semaphore = DispatchSemaphore(value: 0)

Task {
    defer { semaphore.signal() }

    let service = VehicleService()

    do {
        let vehicle = try await service.lookup(vin: vin)
        print("✅ Success!\n")
        print(vehicle.description)
        historyManager.record(vehicle)

        if showHistory {
            print("\n📋 Lookup History (this session):")
            let history = historyManager.history()
            if history.isEmpty {
                print("  (empty)")
            } else {
                for (index, v) in history.enumerated() {
                    let make = v.make ?? "Unknown"
                    let model = v.model ?? "Unknown"
                    let year = v.year ?? "????"
                    print("  \(index + 1). \(year) \(make) \(model) — \(v.vin)")
                }
            }
        }

    } catch let error as VINError {
        print("❌ Error: \(error.errorDescription ?? "Unknown error")")
        print("")
        switch error {
        case .invalidLength:
            print("   Tip: A VIN must be exactly 17 characters. Yours had \(vin.count).")
        case .invalidCharacters:
            print("   Tip: VINs use only uppercase A-Z (excluding I, O, Q) and digits 0-9.")
        case .invalidCheckDigit:
            print("   Tip: The 9th character is a check digit. A typo elsewhere often causes this.")
        case .timeout:
            print("   Tip: Check your internet connection.")
        case .apiError(let text):
            print("   API said: \(text)")
        case .networkIssue(let detail):
            print("   Network detail: \(detail)")
        case .decodingError(let detail):
            print("   Decode detail: \(detail)")
        }
        exit(2)
    } catch {
        print("❌ Unexpected error: \(error.localizedDescription)")
        exit(3)
    }
}

semaphore.wait()
