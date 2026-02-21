import SwiftUI
import VINScoutEngine

/// The single source of truth for all UI state in VIN Scout.
///
/// Marked `@MainActor` so every `@Published` mutation automatically
/// runs on the main thread — no manual `DispatchQueue.main.async` needed.
@MainActor
final class VINScoutViewModel: ObservableObject {

    // MARK: - Input
    @Published var vinInput: String = "" {
        didSet {
            // Auto-uppercase as the user types
            let uppercased = vinInput.uppercased()
            if vinInput != uppercased { vinInput = uppercased }
            // Clear error when user starts editing
            if errorMessage != nil { errorMessage = nil }
        }
    }

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Data
    @Published var recentVehicles: [Vehicle] = []

    // MARK: - Navigation
    /// Setting this to non-nil pushes VehicleDetailView onto the NavigationStack.
    @Published var selectedVehicle: Vehicle? = nil

    // MARK: - Derived
    var characterCount: Int { vinInput.count }
    var isVINComplete: Bool { vinInput.count == 17 }

    /// Color for the character counter.
    /// secondary → orange → green as you approach 17, red if you go over.
    var counterColor: Color {
        switch vinInput.count {
        case 18...:     return .red
        case 17:        return .green
        case 14...16:   return .orange
        default:        return .secondary
        }
    }

    /// Inline warning shown below the text field while the user is still typing.
    /// Nil when there is nothing to warn about.
    var inlineWarning: String? {
        // Over-length: the red counter is enough feedback, no extra text needed
        guard vinInput.count <= 17 else { return nil }
        let forbidden = vinInput.filter { "IOQ".contains($0) }
        guard !forbidden.isEmpty else { return nil }
        let unique = Array(Set(forbidden.map { String($0) }))
            .sorted().joined(separator: ", ")
        return "VINs cannot contain \(unique)"
    }

    // MARK: - Dependencies
    private let service: VehicleService
    private let history: HistoryManager

    // MARK: - Init
    init(
        service: VehicleService = VehicleService(),
        history: HistoryManager = HistoryManager(store: UserDefaultsPersistence())
    ) {
        self.service = service
        self.history = history
        self.recentVehicles = history.history()
    }

    // MARK: - Actions

    /// Validates the VIN, calls the NHTSA API, and updates state accordingly.
    func decode() async {
        let vin = vinInput.trimmingCharacters(in: .whitespaces)
        guard !vin.isEmpty else { return }

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let vehicle = try await service.lookup(vin: vin)
            history.record(vehicle)
            recentVehicles = history.history()
            selectedVehicle = vehicle
        } catch let error as VINError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Selects a vehicle from history to view its details.
    func select(_ vehicle: Vehicle) {
        selectedVehicle = vehicle
    }

    /// Clears all history (for a future "Clear History" button).
    func clearHistory() {
        history.clear()
        recentVehicles = []
    }
}
