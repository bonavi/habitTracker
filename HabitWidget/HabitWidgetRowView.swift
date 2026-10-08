import AppIntents
import SwiftUI

/// Строка привычки: название слева, квадраты дней справа. Сегодняшний квадрат нажимается (+1).
struct HabitWidgetRowView: View {
    let row: HabitWidgetRow
    let days: [Date]
    let today: Date
    let startDate: Date?
    /// Малый виджет: только сегодняшний квадрат, без ссылки на календарь (в малом виджете ссылки не работают).
    let isCompact: Bool

    static let cellSize: CGFloat = 22
    static let cellSpacing: CGFloat = 4

    private var color: Color { HabitColor.color(row.habit.colorIndex) }

    var body: some View {
        HStack(spacing: Self.cellSpacing) {
            if isCompact {
                title
            } else {
                Link(destination: WidgetLink.url(for: row.habit.id)) { title }
            }
            Spacer(minLength: 4)
            ForEach(days, id: \.self) { day in
                cell(for: day)
                    .frame(width: isCompact ? 28 : Self.cellSize, height: isCompact ? 28 : Self.cellSize)
            }
        }
    }

    private var title: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(row.habit.name)
                .font(.caption.weight(.medium))
                .lineLimit(1)
            if let progress = row.progress, !isCompact {
                Text("\(progress.done)/\(progress.goal) · \(row.habit.goalPeriod.shortSuffix)")
                    .font(.system(size: 9))
                    .monospacedDigit()
                    .foregroundStyle(progress.done >= progress.goal ? color : .secondary)
            }
        }
    }

    @ViewBuilder
    private func cell(for day: Date) -> some View {
        if day > today || (startDate.map { day < $0 } ?? false) {
            // Будущие дни и дни до начала отсчёта — пунктиром, не нажимаются
            EmptyDayCell(cornerRadius: 6)
        } else {
            let key = DayKey.string(from: day)
            let content = DayCellContent(
                count: row.counts[key] ?? 0,
                dailyGoal: row.habit.dailyGoal,
                color: color,
                cornerRadius: 6,
                showsOverflowBadge: false
            )
            if day == today {
                Button(intent: IncrementHabitIntent(habitId: row.habit.id, day: key)) { content }
                    .buttonStyle(.plain)
            } else {
                content
            }
        }
    }
}
