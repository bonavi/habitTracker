import Foundation

enum HabitStatus {
    /// Готова ли привычка на сегодня:
    /// - без цели — есть хотя бы одна отметка сегодня;
    /// - дневная цель — достигнута сегодня;
    /// - недельная/месячная — цель периода уже выполнена или есть отметка сегодня.
    static func isDoneToday(
        _ habit: Habit,
        counts: [String: Int],
        today: Date,
        calendar: Calendar = .current
    ) -> Bool {
        let todayCount = counts[DayKey.string(from: today, calendar: calendar)] ?? 0
        switch habit.goalPeriod {
        case .none:
            return todayCount > 0
        case .day:
            return todayCount >= max(habit.goalValue ?? 1, 1)
        case .week, .month:
            if todayCount > 0 { return true }
            guard let progress = ProgressCalculator.progress(for: habit, counts: counts, today: today, calendar: calendar)
            else { return false }
            return progress.done >= progress.goal
        }
    }
}
