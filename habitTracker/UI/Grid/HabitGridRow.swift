import Foundation

/// Строка таблицы: заголовок раздела или привычка.
enum HabitGridRow: Identifiable {
    case header(HabitSectionKind)
    /// `isDone` — привычка в разделе «Готово».
    case habit(Habit, isDone: Bool = false)

    var id: String {
        switch self {
        case .header(let kind): "header-\(kind.rawValue)"
        case .habit(let habit, _): habit.id.uuidString
        }
    }
}
