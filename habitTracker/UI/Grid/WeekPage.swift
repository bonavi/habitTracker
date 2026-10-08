import SwiftUI

/// Одна неделя таблицы — страница горизонтального скролла.
struct WeekPage: View {
    let days: [Date]
    let today: Date
    /// Дни раньше — пунктиром (до начала истории).
    let firstDay: Date
    let rows: [HabitGridRow]
    let counts: [UUID: [String: Int]]
    let onIncrement: (Habit, String) -> Void
    let onDecrement: (Habit, String) -> Void
    let columnWidth: CGFloat
    var labelHeight: CGFloat = 0
    var rowHeight: CGFloat = HabitGridView.rowHeight

    var body: some View {
        let calendar = Calendar.current
        let anchor = days.first ?? today
        VStack(spacing: 0) {
            WeekPageHeader(
                title: WeekLabel.title(for: anchor, today: today, calendar: calendar),
                months: WeekLabel.months(for: anchor, calendar: calendar)
            )
            .frame(height: HabitGridView.weekLabelHeight)

            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    DayColumn(
                        day: day,
                        isToday: day == today,
                        isInactive: day > today || day < firstDay,
                        rows: rows,
                        counts: counts,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                        width: columnWidth,
                        labelHeight: labelHeight,
                        rowHeight: rowHeight
                    )
                }
            }
        }
    }
}
