import Foundation

/// База из общего контейнера App Group, открытая в процессе виджета.
enum WidgetDatabase {
    static let shared: AppDatabase? = try? AppDatabase.makeShared()
}
