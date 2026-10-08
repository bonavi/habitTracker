import Foundation

struct HabitWidgetRow: Identifiable {
    let habit: Habit
    /// день (`yyyy-MM-dd`) -> количество
    let counts: [String: Int]
    let progress: PeriodProgress?

    var id: UUID { habit.id }
}
