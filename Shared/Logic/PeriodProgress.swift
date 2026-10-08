import Foundation

struct PeriodProgress: Equatable, Sendable {
    var done: Int
    var goal: Int
}

enum ProgressCalculator {
    /// Прогресс недельной/месячной цели за период, содержащий `today`.
    /// Неделя начинается по `calendar.firstWeekday` (из локали).
    static func progress(
        for habit: Habit,
        counts: [String: Int],
        today: Date,
        calendar: Calendar = .current
    ) -> PeriodProgress? {
        let component: Calendar.Component
        switch habit.goalPeriod {
        case .week: component = .weekOfYear
        case .month: component = .month
        case .none, .day: return nil
        }
        guard let goal = habit.goalValue, goal > 0,
              let interval = calendar.dateInterval(of: component, for: today) else { return nil }

        var done = 0
        var date = interval.start
        while date < interval.end {
            let count = counts[DayKey.string(from: date, calendar: calendar)] ?? 0
            switch habit.countMode {
            case .sum: done += count
            case .days: done += count > 0 ? 1 : 0
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return PeriodProgress(done: done, goal: goal)
    }

    /// Последний день недели, в которую попадает `date` (неделя — по `calendar.firstWeekday`).
    static func endOfWeek(for date: Date, calendar: Calendar = .current) -> Date {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: date),
              let last = calendar.date(byAdding: .day, value: -1, to: week.end) else { return date }
        return calendar.startOfDay(for: last)
    }

    /// Дни от `start` до `today` включительно, начало дня по календарю.
    static func days(from start: Date, to today: Date, calendar: Calendar = .current) -> [Date] {
        let first = calendar.startOfDay(for: min(start, today))
        let last = calendar.startOfDay(for: today)
        var result: [Date] = []
        var date = first
        while date <= last {
            result.append(date)
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return result
    }
}
