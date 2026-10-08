import XCTest
@testable import habitTracker

final class MonthGridTests: XCTestCase {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    func testLeadingBlanksDependOnFirstWeekday() {
        // 1 октября 2026 — четверг
        let october = DayKey.date(from: "2026-10-01", calendar: calendar(firstWeekday: 2))!
        XCTAssertEqual(MonthGrid.cells(for: october, calendar: calendar(firstWeekday: 2)).prefix { $0 == nil }.count, 3)
        XCTAssertEqual(MonthGrid.cells(for: october, calendar: calendar(firstWeekday: 1)).prefix { $0 == nil }.count, 4)
        XCTAssertEqual(MonthGrid.cells(for: october, calendar: calendar(firstWeekday: 2)).compactMap { $0 }.count, 31)
    }

    func testMonthsRangeInclusive() {
        let cal = calendar(firstWeekday: 2)
        let months = MonthGrid.months(
            from: DayKey.date(from: "2026-08-15", calendar: cal)!,
            to: DayKey.date(from: "2026-10-07", calendar: cal)!,
            calendar: cal
        )
        XCTAssertEqual(months.map { DayKey.string(from: $0, calendar: cal) }, ["2026-08-01", "2026-09-01", "2026-10-01"])
    }

    func testWeekdaySymbolsStartFromFirstWeekday() {
        XCTAssertEqual(MonthGrid.weekdaySymbols(calendar: calendar(firstWeekday: 2)).first?.lowercased(), "пн")
        XCTAssertEqual(MonthGrid.weekdaySymbols(calendar: calendar(firstWeekday: 1)).first?.lowercased(), "вс")
    }
}
