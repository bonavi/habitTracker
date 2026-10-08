import Foundation

/// Ключ дня `yyyy-MM-dd` в часовом поясе календаря. Всегда по григорианскому календарю,
/// чтобы ключи не зависели от календаря локали.
enum DayKey {
    static func string(from date: Date, calendar: Calendar = .current) -> String {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let c = gregorian.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year!, c.month!, c.day!)
    }

    static func date(from key: String, calendar: Calendar = .current) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        return gregorian.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
    }
}
