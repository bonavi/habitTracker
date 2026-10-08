import WidgetKit

struct HabitsEntry: TimelineEntry {
    let date: Date
    let today: Date
    /// Дни текущей недели, которые показывает виджет (могут быть и будущие).
    let days: [Date]
    let rows: [HabitWidgetRow]
    /// Дни раньше этой даты не показываются (начало отсчёта из настроек).
    let startDate: Date?
    /// Есть ли вообще привычки в выборке (до скрытия выполненных) — для текста пустого состояния.
    var hasHabits = true

    static func placeholder(today: Date = Date()) -> HabitsEntry {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: today)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: start)?.start ?? start
        let days = ProgressCalculator.days(
            from: weekStart, to: ProgressCalculator.endOfWeek(for: start, calendar: calendar), calendar: calendar
        )
        let samples = [("Вода", 6, 3), ("Тренировка", 3, 1), ("Чтение", 9, 1)]
        let rows = samples.enumerated().map { index, sample in
            var counts: [String: Int] = [:]
            for (offset, day) in days.enumerated() where day <= start && (offset + index) % 3 != 0 {
                counts[DayKey.string(from: day)] = sample.2
            }
            let habit = Habit(
                name: sample.0, colorIndex: sample.1,
                goalPeriod: sample.2 > 1 ? .day : .none, goalValue: sample.2 > 1 ? sample.2 : nil
            )
            return HabitWidgetRow(habit: habit, counts: counts, progress: nil)
        }
        return HabitsEntry(date: today, today: start, days: days, rows: rows, startDate: nil)
    }
}
