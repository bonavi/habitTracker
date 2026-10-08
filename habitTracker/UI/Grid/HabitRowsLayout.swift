import SwiftUI

/// Раскладка для iPhone: название привычки строкой над её квадратами, дни на всю ширину.
/// Названия лежат поверх горизонтального скролла и не двигаются вместе с днями.
struct HabitRowsLayout: View {
    let viewModel: HabitsViewModel
    let onOpen: (Habit) -> Void
    let onEdit: (Habit) -> Void

    private static let labelHeight: CGFloat = 22
    private static let cellRowHeight: CGFloat = 44
    private static let horizontalPadding: CGFloat = 12

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

            GeometryReader { proxy in
                // Неделя — ровно ширина экрана, 7 колонок
                let pageWidth = proxy.size.width - Self.horizontalPadding * 2
                let columnWidth = pageWidth / 7

                ScrollView(.vertical) {
                    ZStack(alignment: .topLeading) {
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
                                        columnWidth: columnWidth,
                                        labelHeight: Self.labelHeight,
                                        rowHeight: Self.cellRowHeight
                                    )
                                    .frame(width: pageWidth)
                                }
                            }
                            .scrollTargetLayout()
                        }
                        // Листается по неделям
                        .scrollTargetBehavior(.viewAligned)
                        .defaultScrollAnchor(.trailing)
                        .padding(.horizontal, Self.horizontalPadding)

                        labels(rows)
                    }
                }
            }
        }
    }

    private func labels(_ rows: [HabitGridRow]) -> some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return VStack(alignment: .leading, spacing: 0) {
            Color.clear
                .frame(height: HabitGridView.headerHeight)
                .allowsHitTesting(false)
            ForEach(rows) { row in
                switch row {
                case .header(let kind):
                    HabitSectionHeader(kind: kind, count: sectionCount(kind, in: rows))
                        .frame(height: HabitGridView.sectionHeaderHeight)
                        .padding(.horizontal, Self.horizontalPadding)
                        .allowsHitTesting(false)
                case .habit(let habit, _):
                    label(habit, today: today, calendar: calendar)
                }
            }
        }
    }

    @ViewBuilder
    private func label(_ habit: Habit, today: Date, calendar: Calendar) -> some View {
                HabitNameCell(
                    habit: habit,
                    progress: ProgressCalculator.progress(
                        for: habit, counts: viewModel.counts(for: habit), today: today, calendar: calendar
                    ),
                    onOpen: { onOpen(habit) },
                    onEdit: { onEdit(habit) },
                    onArchive: { viewModel.setArchived(habit, true) },
                    onDelete: { viewModel.delete(habit) },
                    isInline: true
                )
                .fixedSize(horizontal: true, vertical: false)
                .frame(height: Self.labelHeight, alignment: .bottomLeading)
                .padding(.leading, Self.horizontalPadding + 4)
                Color.clear
                    .frame(height: Self.cellRowHeight)
                    .allowsHitTesting(false)
    }
}
