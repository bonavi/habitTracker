import XCTest
@testable import habitTracker

final class WeekLabelTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Moscow")!
        calendar.locale = Locale(identifier: "ru_RU")
        calendar.firstWeekday = 2
        calendar.minimumDaysInFirstWeek = 4
        return calendar
    }()

    private func date(_ key: String) -> Date { DayKey.date(from: key, calendar: calendar)! }

    func testTitlesWithWeekNumbers() {
        let today = date("2026-10-07")
        XCTAssertEqual(WeekLabel.title(for: date("2026-10-05"), today: today, calendar: calendar), "Эта неделя · 41")
        XCTAssertEqual(WeekLabel.title(for: date("2026-09-28"), today: today, calendar: calendar), "Прошлая неделя · 40")
        XCTAssertEqual(WeekLabel.title(for: date("2026-09-21"), today: today, calendar: calendar), "Неделя 39")
    }

    func testMonthsSingleAndCrossing() {
        XCTAssertEqual(WeekLabel.months(for: date("2026-10-05"), calendar: calendar), "Октябрь")
        XCTAssertEqual(WeekLabel.months(for: date("2026-09-28"), calendar: calendar), "Сентябрь → Октябрь")
    }
}
