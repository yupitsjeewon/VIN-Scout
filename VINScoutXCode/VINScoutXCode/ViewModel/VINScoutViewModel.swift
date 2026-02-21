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

    // MARK: - Appearance
    /// Persisted preference: "system", "light", or "dark".
    @AppStorage("colorSchemePreference") var colorSchemePreference: String = "system"

    /// The SwiftUI ColorScheme to apply at the root. Nil = follow system.
    var preferredColorScheme: ColorScheme? {
        switch colorSchemePreference {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    /// SF Symbol name for the current appearance mode button.
    var colorSchemeIcon: String {
        switch colorSchemePreference {
        case "light": return "sun.max.fill"
        case "dark":  return "moon.fill"
        default:      return "circle.lefthalf.filled"
        }
    }

    /// Cycles system → light → dark → system.
    func cycleColorScheme() {
        switch colorSchemePreference {
        case "system": colorSchemePreference = "light"
        case "light":  colorSchemePreference = "dark"
        default:       colorSchemePreference = "system"
        }
    }

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
    /// The currently in-flight decode task. Kept so we can cancel it if the
    /// user taps Decode again before the previous call finishes.
    private var currentDecodeTask: Task<Void, Never>?

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

    /// Kicks off a VIN decode, cancelling any previous in-flight request first.
    ///
    /// Key design decisions:
    /// - `decode()` is NOT async. It owns a `Task` internally so callers
    ///   (buttons, `.onSubmit`) can call it without needing `Task { await ... }`.
    /// - `currentDecodeTask?.cancel()` runs before every new request, so only
    ///   the latest tap ever updates the UI.
    /// - After every `await`, we check `Task.isCancelled` so a stale response
    ///   that arrives late is silently discarded rather than overwriting a newer result.
    /// - `CancellationError` is caught separately and ignored — it is not an
    ///   error the user caused, so we never show it in the error banner.
    func decode() {
        let vin = vinInput.trimmingCharacters(in: .whitespaces)
        guard !vin.isEmpty else { return }

        // Cancel the previous request before starting a new one
        currentDecodeTask?.cancel()

        currentDecodeTask = Task {
            errorMessage = nil
            isLoading = true
            defer { isLoading = false }

            do {
                let vehicle = try await service.lookup(vin: vin)

                // Discard result if this task was cancelled while the network
                // call was in-flight (user tapped Decode again with a new VIN)
                guard !Task.isCancelled else { return }

                history.record(vehicle)
                recentVehicles = history.history()
                selectedVehicle = vehicle

            } catch is CancellationError {
                // Silently ignore — a newer decode() call is already running
            } catch let error as VINError {
                guard !Task.isCancelled else { return }
                errorMessage = error.errorDescription
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
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
