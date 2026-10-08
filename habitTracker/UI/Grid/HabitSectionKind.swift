import Foundation

/// Разделы главного экрана при включённой группировке.
enum HabitSectionKind: String {
    case pending
    case done

    var title: String {
        switch self {
        case .pending: "Осталось"
        case .done: "Готово"
        }
    }
}
