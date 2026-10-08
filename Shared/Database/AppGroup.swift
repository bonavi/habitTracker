import Foundation

/// Общий контейнер приложения и виджета.
enum AppGroup {
    static let identifier = "group.bonavi.habitTracker"

    static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
