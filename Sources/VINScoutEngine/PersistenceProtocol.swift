import Foundation

/// Abstracts the persistence layer for `HistoryManager`.
/// Conformers can back this with UserDefaults, Core Data, the file system,
/// or an in-memory array (for testing on Windows).
public protocol PersistenceStore: AnyObject {
    /// Persists the provided list of vehicles, overwriting any previously stored data.
    func save(_ vehicles: [Vehicle]) throws

    /// Loads and returns the previously persisted list of vehicles.
    /// Returns an empty array if no data has been saved yet.
    func load() throws -> [Vehicle]
}
