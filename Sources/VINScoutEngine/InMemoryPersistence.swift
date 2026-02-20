import Foundation

/// A thread-safe, in-memory implementation of `PersistenceStore`.
///
/// Data is held in a plain array and lost when the process exits.
/// This is intentional — it makes the `HistoryManager` fully testable on Windows
/// without needing `UserDefaults` or a file system.
public final class InMemoryPersistence: PersistenceStore {

    // MARK: - Private State
    private var store: [Vehicle] = []
    private let lock = NSLock()

    public init() {}

    // MARK: - PersistenceStore

    public func save(_ vehicles: [Vehicle]) throws {
        lock.lock()
        defer { lock.unlock() }
        store = vehicles
    }

    public func load() throws -> [Vehicle] {
        lock.lock()
        defer { lock.unlock() }
        return store
    }
}
