import Foundation

/// Раскладка месяцев для календарного вида.
enum MonthGrid {
    /// Начала месяцев от месяца `start` до месяца `end` включительно.
    static func months(from start: Date, to end: Date, calendar: Calendar = .current) -> [Date] {
        guard let first = calendar.dateInterval(of: .month, for: min(start, end))?.start,
              let last = calendar.dateInterval(of: .month, for: end)?.start else { return [] }
        var result: [Date] = []
        var month = first
        while month <= last {
            result.append(month)
            guard let next = calendar.date(byAdding: .month, value: 1, to: month) else { break }
            month = next
        }
        return result
    }

    /// Дни месяца с ведущими пустыми ячейками (`nil`), чтобы первый день встал под свой день недели.
    static func cells(for month: Date, calendar: Calendar = .current) -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let weekday = calendar.component(.weekday, from: interval.start)
        let leading = (weekday - calendar.firstWeekday + 7) % 7
        var result: [Date?] = Array(repeating: nil, count: leading)
        var day = interval.start
        while day < interval.end {
            result.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = next
        }
        return result
    }

    /// Короткие названия дней недели по локали, начиная с первого дня недели.
    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        return Array(symbols[shift...] + symbols[..<shift])
    }
}
