import XCTest
@testable import habitTracker

final class ProgressCalculatorTests: XCTestCase {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    private func date(_ key: String, _ calendar: Calendar) -> Date {
        DayKey.date(from: key, calendar: calendar)!
    }

    // 2026-10-07 — среда. 2026-10-04 — воскресенье, 2026-10-05 — понедельник.
    private let counts = ["2026-10-04": 2, "2026-10-05": 1, "2026-10-07": 3, "2026-09-30": 5]

    func testWeekSumStartingMonday() {
        let cal = calendar(firstWeekday: 2)
        let habit = Habit(name: "Тренировки", goalPeriod: .week, goalValue: 4, countMode: .sum)
        let result = ProgressCalculator.progress(for: habit, counts: counts, today: date("2026-10-07", cal), calendar: cal)
        XCTAssertEqual(result, PeriodProgress(done: 4, goal: 4))
    }

    func testWeekSumStartingSundayIncludesSunday() {
        let cal = calendar(firstWeekday: 1)
        let habit = Habit(name: "Тренировки", goalPeriod: .week, goalValue: 4, countMode: .sum)
        let result = ProgressCalculator.progress(for: habit, counts: counts, today: date("2026-10-07", cal), calendar: cal)
        XCTAssertEqual(result, PeriodProgress(done: 6, goal: 4))
    }

    func testWeekDaysMode() {
        let cal = calendar(firstWeekday: 2)
        let habit = Habit(name: "Тренировки", goalPeriod: .week, goalValue: 3, countMode: .days)
        let result = ProgressCalculator.progress(for: habit, counts: counts, today: date("2026-10-07", cal), calendar: cal)
        XCTAssertEqual(result, PeriodProgress(done: 2, goal: 3))
    }

    func testMonthExcludesPreviousMonth() {
        let cal = calendar(firstWeekday: 2)
        let habit = Habit(name: "Чтение", goalPeriod: .month, goalValue: 20, countMode: .sum)
        let result = ProgressCalculator.progress(for: habit, counts: counts, today: date("2026-10-07", cal), calendar: cal)
        XCTAssertEqual(result, PeriodProgress(done: 6, goal: 20))
    }

    func testNoProgressForDailyOrNoGoal() {
        let cal = calendar(firstWeekday: 2)
        let today = date("2026-10-07", cal)
        XCTAssertNil(ProgressCalculator.progress(for: Habit(name: "a"), counts: counts, today: today, calendar: cal))
        XCTAssertNil(ProgressCalculator.progress(for: Habit(name: "b", goalPeriod: .day, goalValue: 2), counts: counts, today: today, calendar: cal))
    }

    func testDaysRangeInclusive() {
        let cal = calendar(firstWeekday: 2)
        let days = ProgressCalculator.days(from: date("2026-10-01", cal), to: date("2026-10-07", cal), calendar: cal)
        XCTAssertEqual(days.map { DayKey.string(from: $0, calendar: cal) }.first, "2026-10-01")
        XCTAssertEqual(days.count, 7)
    }
}
