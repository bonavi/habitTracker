import SwiftUI

struct MonthView: View {
    let month: Date
    let habit: Habit
    let counts: [String: Int]
    /// Дни раньше этой даты не отмечаются (до создания привычки или начала отсчёта).
    let firstDay: Date
    let today: Date
    let onIncrement: (String) -> Void
    let onDecrement: (String) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        let calendar = Calendar.current
        let cells = MonthGrid.cells(for: month, calendar: calendar)
        // Итог месяца — только по дням с начала истории (отметки до даты начала скрыты)
        let monthKeys = cells.compactMap { $0 }
            .filter { $0 >= firstDay && $0 <= today }
            .map { DayKey.string(from: $0, calendar: calendar) }
        let doneDays = monthKeys.filter { (counts[$0] ?? 0) > 0 }.count
        let total = monthKeys.reduce(0) { $0 + (counts[$1] ?? 0) }

        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(month, format: .dateTime.month(.wide).year())
                    .font(.title3.weight(.semibold))
                Spacer()
                if total > 0 {
                    Text("\(doneDays) дн. · \(total)")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        dayView(day, calendar: calendar)
                    } else {
                        Color.clear.frame(height: 1)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayView(_ day: Date, calendar: Calendar) -> some View {
        let key = DayKey.string(from: day, calendar: calendar)
        let isActive = day >= firstDay && day <= today
        let isToday = day == today

        VStack(spacing: 3) {
            if isActive {
                DayCell(
                    count: counts[key] ?? 0,
                    dailyGoal: habit.dailyGoal,
                    color: HabitColor.color(habit.colorIndex),
                    onIncrement: { onIncrement(key) },
                    onDecrement: { onDecrement(key) }
                )
                .aspectRatio(1, contentMode: .fit)
            } else {
                // Будущие дни и дни до начала истории — пунктиром
                EmptyDayCell()
                    .aspectRatio(1, contentMode: .fit)
            }
            Text(day, format: .dateTime.day())
                .font(.caption2.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(isActive ? .secondary : .tertiary))
        }
    }
}
