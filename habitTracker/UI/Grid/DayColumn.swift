import SwiftUI

struct DayColumn: View {
    let day: Date
    let isToday: Bool
    /// Будущий день или день до начала истории: квадраты пунктирные и не нажимаются.
    var isInactive = false
    let rows: [HabitGridRow]
    let counts: [UUID: [String: Int]]
    let onIncrement: (Habit, String) -> Void
    let onDecrement: (Habit, String) -> Void
    var width: CGFloat = HabitGridView.columnWidth
    /// Место над квадратом под строку с названием (двустрочная раскладка).
    var labelHeight: CGFloat = 0
    var rowHeight: CGFloat = HabitGridView.rowHeight
    var sectionHeaderHeight: CGFloat = HabitGridView.sectionHeaderHeight

    var body: some View {
        let key = DayKey.string(from: day)
        VStack(spacing: 0) {
            DayHeader(day: day, isToday: isToday)
                .opacity(isInactive ? 0.4 : 1)
                .frame(height: HabitGridView.headerHeight - HabitGridView.weekLabelHeight)
            ForEach(rows) { row in
                switch row {
                case .header:
                    Color.clear.frame(height: sectionHeaderHeight)
                case .habit(let habit, _):
                    Group {
                    if isInactive {
                        EmptyDayCell()
                            .frame(width: HabitGridView.cellSize, height: HabitGridView.cellSize)
                            .frame(height: rowHeight)
                            .padding(.top, labelHeight)
                    } else {
                        cell(habit, key: key)
                    }
                    }
                }
            }
        }
        .frame(width: width)
    }

    private func cell(_ habit: Habit, key: String) -> some View {
                DayCell(
                    count: counts[habit.id]?[key] ?? 0,
                    dailyGoal: habit.dailyGoal,
                    color: HabitColor.color(habit.colorIndex),
                    onIncrement: { onIncrement(habit, key) },
                    onDecrement: { onDecrement(habit, key) }
                )
                .frame(width: HabitGridView.cellSize, height: HabitGridView.cellSize)
                .frame(height: rowHeight)
                .padding(.top, labelHeight)
    }
}
