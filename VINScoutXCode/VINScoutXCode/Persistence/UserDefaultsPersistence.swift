import Foundation
import VINScoutEngine

/// A `PersistenceStore` conformer that stores the Vehicle history in `UserDefaults`
/// as a JSON-encoded `Data` blob. This gives VINScout cross-session history
/// on iOS/macOS with no changes required to `HistoryManager`.
final class UserDefaultsPersistence: PersistenceStore {

    // MARK: - Constants
    private let key = "vin_scout_history_v1"

    // MARK: - PersistenceStore

    func save(_ vehicles: [Vehicle]) throws {
        let data = try JSONEncoder().encode(vehicles)
        UserDefaults.standard.set(data, forKey: key)
    }

    func load() throws -> [Vehicle] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        return try JSONDecoder().decode([Vehicle].self, from: data)
    }
}
