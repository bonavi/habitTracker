import Foundation
import GRDB

struct Habit: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var name: String
    var colorIndex: Int
    var sortOrder: Int
    var goalPeriod: GoalPeriod
    var goalValue: Int?
    var countMode: CountMode
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    var deletedAt: Date?

    init(
        id: UUID = UUID(),
        name: String,
        colorIndex: Int = 0,
        sortOrder: Int = 0,
        goalPeriod: GoalPeriod = .none,
        goalValue: Int? = nil,
        countMode: CountMode = .sum,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.colorIndex = colorIndex
        self.sortOrder = sortOrder
        self.goalPeriod = goalPeriod
        self.goalValue = goalValue
        self.countMode = countMode
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    /// Дневная цель, если она задана (влияет на секторы в ячейке дня).
    var dailyGoal: Int? {
        guard goalPeriod == .day, let goalValue, goalValue > 0 else { return nil }
        return goalValue
    }
}

extension Habit: FetchableRecord, PersistableRecord {
    static let databaseTableName = "habit"
}
