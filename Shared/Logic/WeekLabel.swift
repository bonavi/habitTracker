import Foundation

/// Подписи недели над таблицей.
enum WeekLabel {
    /// «Эта неделя · 41», «Прошлая неделя · 40», раньше — «Неделя 39». Номер недели — по календарю локали.
    static func title(for day: Date, today: Date, calendar: Calendar = .current) -> String {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: day),
              let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today) else { return "" }
        let number = calendar.component(.weekOfYear, from: week.start)

        if week.start == currentWeek.start { return "Эта неделя · \(number)" }
        if let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek.start),
           week.start == previous {
            return "Прошлая неделя · \(number)"
        }
        return "Неделя \(number)"
    }

    /// Месяц недели: «Октябрь» или, если неделя на стыке, «Сентябрь → Октябрь».
    static func months(for day: Date, calendar: Calendar = .current) -> String {
        guard let week = calendar.dateInterval(of: .weekOfYear, for: day),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: week.end) else { return "" }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = calendar.locale ?? .current
        formatter.dateFormat = "LLLL"
        let first = formatter.string(from: week.start).capitalized(with: formatter.locale)
        let last = formatter.string(from: lastDay).capitalized(with: formatter.locale)
        return first == last ? first : "\(first) → \(last)"
    }
}
