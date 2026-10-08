import Foundation
import GRDB

/// Количество выполнений привычки за конкретный день.
struct HabitEntry: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var habitId: UUID
    /// День в формате `yyyy-MM-dd`, см. `DayKey`.
    var day: String
    var count: Int
    var updatedAt: Date
    var deletedAt: Date?
}

extension HabitEntry: FetchableRecord, PersistableRecord {
    static let databaseTableName = "habitEntry"
}
