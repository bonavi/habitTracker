import SwiftUI

/// Таблица: строки — привычки, столбцы — дни (сегодня справа).
/// На iPhone — двустрочная раскладка, на широких экранах — названия колонкой слева.
struct HabitGridView: View {
    let viewModel: HabitsViewModel
    let onOpen: (Habit) -> Void
    let onEdit: (Habit) -> Void

    static let rowHeight: CGFloat = 56
    static let headerHeight: CGFloat = 58
    static let weekLabelHeight: CGFloat = 18
    static let sectionHeaderHeight: CGFloat = 30
    static let cellSize: CGFloat = 36
    static let columnWidth: CGFloat = 44
    static let nameWidth: CGFloat = 130

    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            HabitColumnsLayout(viewModel: viewModel, onOpen: onOpen, onEdit: onEdit)
        } else {
            HabitRowsLayout(viewModel: viewModel, onOpen: onOpen, onEdit: onEdit)
        }
    }
}
