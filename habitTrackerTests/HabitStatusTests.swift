import XCTest
@testable import habitTracker

final class HabitStatusTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        calendar.firstWeekday = 2
        return calendar
    }()

    private var today: Date { DayKey.date(from: "2026-10-07", calendar: calendar)! }

    func testNoGoalDoneWithAnyMarkToday() {
        let habit = Habit(name: "a")
        XCTAssertFalse(HabitStatus.isDoneToday(habit, counts: ["2026-10-06": 3], today: today, calendar: calendar))
        XCTAssertTrue(HabitStatus.isDoneToday(habit, counts: ["2026-10-07": 1], today: today, calendar: calendar))
    }

    func testDailyGoalNeedsFullGoal() {
        let habit = Habit(name: "a", goalPeriod: .day, goalValue: 3)
        XCTAssertFalse(HabitStatus.isDoneToday(habit, counts: ["2026-10-07": 2], today: today, calendar: calendar))
        XCTAssertTrue(HabitStatus.isDoneToday(habit, counts: ["2026-10-07": 3], today: today, calendar: calendar))
    }

    func testWeeklyGoalDoneWhenPeriodReachedOrMarkedToday() {
        let habit = Habit(name: "a", goalPeriod: .week, goalValue: 2)
        XCTAssertFalse(HabitStatus.isDoneToday(habit, counts: ["2026-10-05": 1], today: today, calendar: calendar))
        XCTAssertTrue(HabitStatus.isDoneToday(habit, counts: ["2026-10-05": 1, "2026-10-06": 1], today: today, calendar: calendar))
        XCTAssertTrue(HabitStatus.isDoneToday(habit, counts: ["2026-10-07": 1], today: today, calendar: calendar))
    }
}
