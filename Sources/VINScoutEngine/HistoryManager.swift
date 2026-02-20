import Foundation

/// Manages a persisted list of the last 5 VIN lookups.
///
/// # Usage
/// ```swift
/// let history = HistoryManager()          // Uses InMemoryPersistence by default
/// history.record(vehicle)
/// let recent = history.history()          // Returns up to 5 vehicles
/// ```
///
/// Inject a custom `PersistenceStore` to use `UserDefaults`, Core Data, etc.
public final class HistoryManager {

    // MARK: - Constants
    public static let maxItems = 5

    // MARK: - Dependencies
    private let store: PersistenceStore

    // MARK: - Init
    /// Creates a new `HistoryManager`.
    /// - Parameter store: The backing persistence store. Defaults to `InMemoryPersistence`.
    public init(store: PersistenceStore = InMemoryPersistence()) {
        self.store = store
    }

    // MARK: - Public API

    /// Records a vehicle lookup, prepending it to the history.
    /// If the VIN already exists in history, the old entry is removed (deduplication).
    /// Keeps only the last `maxItems` entries.
    ///
    /// - Parameter vehicle: The successfully decoded `Vehicle` to record.
    public func record(_ vehicle: Vehicle) {
        var current = (try? store.load()) ?? []

        // Deduplicate: remove previous entry for the same VIN if present
        current.removeAll { $0.vin.uppercased() == vehicle.vin.uppercased() }

        // Prepend newest first
        current.insert(vehicle, at: 0)

        // Cap at max items
        if current.count > HistoryManager.maxItems {
            current = Array(current.prefix(HistoryManager.maxItems))
        }

        try? store.save(current)
    }

    /// Returns the lookup history, newest first, up to `maxItems` entries.
    public func history() -> [Vehicle] {
        (try? store.load()) ?? []
    }

    /// Clears all stored history.
    public func clear() {
        try? store.save([])
    }
}
