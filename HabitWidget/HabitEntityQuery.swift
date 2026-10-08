import AppIntents

struct HabitEntityQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        try allHabits().filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [HabitEntity] {
        try allHabits()
    }

    /// Только активные (не архивные) привычки, в порядке из приложения.
    private func allHabits() throws -> [HabitEntity] {
        guard let database = WidgetDatabase.shared else { return [] }
        return try database.snapshot(archived: false).habits.map { HabitEntity(id: $0.id, name: $0.name) }
    }
}
