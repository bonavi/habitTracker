import AppIntents
import WidgetKit

/// +1 к выполнению привычки за день — по тапу на квадрат в виджете.
struct IncrementHabitIntent: AppIntent {
    static let title: LocalizedStringResource = "Отметить привычку"
    static let isDiscoverable = false

    @Parameter(title: "Привычка")
    var habitId: String

    @Parameter(title: "День")
    var day: String

    init() {}

    init(habitId: UUID, day: String) {
        self.habitId = habitId.uuidString
        self.day = day
    }

    func perform() async throws -> some IntentResult {
        guard let id = UUID(uuidString: habitId), let database = WidgetDatabase.shared else { return .result() }
        try database.changeCount(habitId: id, day: day, by: 1)
        return .result()
    }
}
