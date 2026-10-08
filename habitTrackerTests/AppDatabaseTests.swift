import XCTest
@testable import habitTracker

final class AppDatabaseTests: XCTestCase {
    func testIncrementDecrementNeverBelowZero() throws {
        let db = try AppDatabase.makeInMemory()
        let habit = Habit(name: "Вода")
        try db.save(habit)

        try db.changeCount(habitId: habit.id, day: "2026-10-07", by: 1)
        try db.changeCount(habitId: habit.id, day: "2026-10-07", by: 1)
        XCTAssertEqual(try db.snapshot(archived: false).counts[habit.id]?["2026-10-07"], 2)

        for _ in 0..<3 { try db.changeCount(habitId: habit.id, day: "2026-10-07", by: -1) }
        XCTAssertNil(try db.snapshot(archived: false).counts[habit.id]?["2026-10-07"])

        try db.changeCount(habitId: habit.id, day: "2026-10-07", by: 1)
        XCTAssertEqual(try db.snapshot(archived: false).counts[habit.id]?["2026-10-07"], 1)
    }

    func testArchiveAndSoftDelete() throws {
        let db = try AppDatabase.makeInMemory()
        let a = Habit(name: "A"), b = Habit(name: "B")
        try db.save(a)
        try db.save(b)

        try db.setArchived(a.id, true)
        XCTAssertEqual(try db.snapshot(archived: false).habits.map(\.name), ["B"])
        XCTAssertEqual(try db.snapshot(archived: true).habits.map(\.name), ["A"])

        try db.delete(a.id)
        XCTAssertTrue(try db.snapshot(archived: true).habits.isEmpty)
    }

    func testNewHabitsAppendAndReorder() throws {
        let db = try AppDatabase.makeInMemory()
        let a = Habit(name: "A"), b = Habit(name: "B"), c = Habit(name: "C")
        for habit in [a, b, c] { try db.save(habit) }
        XCTAssertEqual(try db.snapshot(archived: false).habits.map(\.name), ["A", "B", "C"])

        try db.reorder([c.id, a.id, b.id])
        XCTAssertEqual(try db.snapshot(archived: false).habits.map(\.name), ["C", "A", "B"])
    }

    func testGoalFieldsRoundTrip() throws {
        let db = try AppDatabase.makeInMemory()
        let habit = Habit(name: "Тренировки", colorIndex: 3, goalPeriod: .week, goalValue: 4, countMode: .days)
        try db.save(habit)
        let stored = try XCTUnwrap(db.snapshot(archived: false).habits.first)
        XCTAssertEqual(stored.goalPeriod, .week)
        XCTAssertEqual(stored.goalValue, 4)
        XCTAssertEqual(stored.countMode, .days)
        XCTAssertEqual(stored.colorIndex, 3)
    }
}

extension AppDatabaseTests {
    func testStartDaySettingSetAndClear() throws {
        let db = try AppDatabase.makeInMemory()
        XCTAssertNil(try db.snapshot(archived: false).startDay)

        try db.setSetting(.startDay, "2026-10-03")
        XCTAssertEqual(try db.snapshot(archived: false).startDay, "2026-10-03")

        try db.setSetting(.startDay, "2026-10-05")
        XCTAssertEqual(try db.snapshot(archived: false).startDay, "2026-10-05")

        try db.setSetting(.startDay, nil)
        XCTAssertNil(try db.snapshot(archived: false).startDay)
    }
}
