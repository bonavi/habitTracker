import Foundation
import GRDB
import Observation
import OSLog
import WidgetKit

private let logger = Logger(subsystem: "habitTracker", category: "HabitsViewModel")

@MainActor
@Observable
final class HabitsViewModel {
    let database: AppDatabase
    let archived: Bool
    private(set) var snapshot = HabitsSnapshot()

    init(database: AppDatabase, archived: Bool) {
        self.database = database
        self.archived = archived
    }

    func observe() async {
        do {
            for try await value in database.observeSnapshot(archived: archived) {
                snapshot = value
            }
        } catch {
            logger.error("Observation failed: \(error)")
        }
    }

    var startDate: Date? {
        snapshot.startDay.flatMap { DayKey.date(from: $0) }
    }

    func setStartDate(_ date: Date?) {
        perform { try $0.setSetting(.startDay, date.map { DayKey.string(from: $0) }) }
    }

    func setGroupByDone(_ value: Bool) {
        perform { try $0.setSetting(.groupByDone, value ? "1" : nil) }
    }

    /// Строки таблицы: при включённой группировке невыполненные сверху, ниже — раздел «Готово».
    func rows(today: Date) -> [HabitGridRow] {
        let habits = snapshot.habits
        guard snapshot.groupByDone else { return habits.map { .habit($0) } }

        var pending: [Habit] = []
        var done: [Habit] = []
        for habit in habits {
            if HabitStatus.isDoneToday(habit, counts: counts(for: habit), today: today) {
                done.append(habit)
            } else {
                pending.append(habit)
            }
        }

        // «Осталось» идёт сверху без заголовка; «Готово» отделено разделителем
        var rows: [HabitGridRow] = pending.map { .habit($0) }
        if !done.isEmpty {
            rows.append(.header(.done))
            rows += done.map { .habit($0, isDone: true) }
        }
        return rows
    }

    func counts(for habit: Habit) -> [String: Int] {
        snapshot.counts[habit.id] ?? [:]
    }

    /// Первый день таблицы — дата начала отсчёта из настроек, если задана,
    /// иначе дата создания самой старой привычки или самая ранняя отметка.
    func firstDay(today: Date) -> Date {
        if let startDate { return min(startDate, today) }
        var first = snapshot.habits.map(\.createdAt).min() ?? today
        for dayCounts in snapshot.counts.values {
            for key in dayCounts.keys {
                if let date = DayKey.date(from: key), date < first { first = date }
            }
        }
        // Минимум неделя, чтобы таблица не была пустой
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: today) ?? today
        return min(first, weekAgo)
    }

    /// Первый день истории конкретной привычки: начало отсчёта из настроек,
    /// иначе дата создания привычки или её самая ранняя отметка.
    func firstDay(for habit: Habit, today: Date) -> Date {
        if let startDate { return min(startDate, today) }
        var first = habit.createdAt
        for key in counts(for: habit).keys {
            if let date = DayKey.date(from: key), date < first { first = date }
        }
        return min(first, today)
    }

    func increment(_ habit: Habit, day: String) { perform { try $0.changeCount(habitId: habit.id, day: day, by: 1) } }
    func decrement(_ habit: Habit, day: String) { perform { try $0.changeCount(habitId: habit.id, day: day, by: -1) } }
    func save(_ habit: Habit) { perform { try $0.save(habit) } }
    func setArchived(_ habit: Habit, _ value: Bool) { perform { try $0.setArchived(habit.id, value) } }
    func delete(_ habit: Habit) { perform { try $0.delete(habit.id) } }
    func reorder(_ ids: [UUID]) { perform { try $0.reorder(ids) } }

    private func perform(_ action: (AppDatabase) throws -> Void) {
        do {
            try action(database)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            logger.error("Database write failed: \(error)")
        }
    }
}
