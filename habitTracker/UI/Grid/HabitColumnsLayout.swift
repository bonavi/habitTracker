import SwiftUI

/// Раскладка для широких экранов (iPad): названия в колонке слева, дни — справа.
struct HabitColumnsLayout: View {
    let viewModel: HabitsViewModel
    let onOpen: (Habit) -> Void
    let onEdit: (Habit) -> Void


    var body: some View {
        TimelineView(.everyMinute) { context in
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: context.date)
            // До конца текущей недели: будущие дни видны, но не отмечаются
            let lastDay = ProgressCalculator.endOfWeek(for: today, calendar: calendar)
            // С начала недели, в которую попадает первый день истории: дни до него — пунктиром
            let firstDay = calendar.startOfDay(for: viewModel.firstDay(today: today))
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: firstDay)?.start ?? firstDay
            let days = ProgressCalculator.days(from: weekStart, to: lastDay, calendar: calendar)
            let rows = viewModel.rows(today: today)

            ScrollView(.vertical) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(height: HabitGridView.headerHeight)
                        ForEach(rows) { row in
                            switch row {
                            case .header(let kind):
                                HabitSectionHeader(kind: kind, count: sectionCount(kind, in: rows))
                                    .frame(height: HabitGridView.sectionHeaderHeight)
                            case .habit(let habit, _):
                            HabitNameCell(
                                habit: habit,
                                progress: ProgressCalculator.progress(
                                    for: habit, counts: viewModel.counts(for: habit), today: today, calendar: calendar
                                ),
                                onOpen: { onOpen(habit) },
                                onEdit: { onEdit(habit) },
                                onArchive: { viewModel.setArchived(habit, true) },
                                onDelete: { viewModel.delete(habit) }
                            )
                            .frame(width: HabitGridView.nameWidth, height: HabitGridView.rowHeight, alignment: .leading)
                            }
                        }
                    }
                    .frame(width: HabitGridView.nameWidth)
                    .padding(.leading)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(weekChunks(days), id: \.first) { week in
                                WeekPage(
                                    days: week,
                                    today: today,
                                    firstDay: firstDay,
                                    rows: rows,
                                    counts: viewModel.snapshot.counts,
                                    onIncrement: { viewModel.increment($0, day: $1) },
                                    onDecrement: { viewModel.decrement($0, day: $1) },
                                    columnWidth: HabitGridView.columnWidth
                                )
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.trailing, 8)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .defaultScrollAnchor(.trailing)
                }
            }
        }
    }
}
