import Foundation

/// Ссылки из виджета в приложение: `habittracker://habit/<uuid>` открывает календарь привычки.
enum WidgetLink {
    static func url(for habitId: UUID) -> URL {
        URL(string: "habittracker://habit/\(habitId.uuidString)")!
    }

    static func habitId(from url: URL) -> UUID? {
        guard url.scheme == "habittracker", url.host == "habit" else { return nil }
        return UUID(uuidString: url.lastPathComponent)
    }
}
