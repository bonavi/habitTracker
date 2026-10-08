import SwiftUI

/// Полноэкранная история одной привычки по месяцам.
struct HabitCalendarScreen: View {
    let viewModel: HabitsViewModel
    let habitId: UUID

    @State private var editing: Habit?
    @Environment(\.dismiss) private var dismiss

    private var habit: Habit? {
        viewModel.snapshot.habits.first { $0.id == habitId }
    }

    var body: some View {
        Group {
            if let habit {
                content(habit)
            } else {
                // Привычку архивировали или удалили, пока экран был открыт
                ContentUnavailableView("Привычка недоступна", systemImage: "questionmark.square.dashed")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editing) { habit in
            HabitEditorSheet(habit: habit) { viewModel.save($0) }
        }
    }

    private func content(_ habit: Habit) -> some View {
        TimelineView(.everyMinute) { context in
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: context.date)
            let firstDay = calendar.startOfDay(for: viewModel.firstDay(for: habit, today: today))
            let counts = viewModel.counts(for: habit)

            let months = MonthGrid.months(from: firstDay, to: today, calendar: calendar)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 28) {
                        ForEach(months, id: \.self) { month in
                            MonthView(
                                month: month,
                                habit: habit,
                                counts: counts,
                                firstDay: firstDay,
                                today: today,
                                onIncrement: { viewModel.increment(habit, day: $0) },
                                onDecrement: { viewModel.decrement(habit, day: $0) }
                            )
                            .padding(.horizontal)
                            .id(month)
                        }
                    }
                    .padding(.vertical)
                }
                // Дни недели вне скролла — всегда прибиты под навбаром
                .safeAreaInset(edge: .top, spacing: 0) {
                    WeekdaySymbolsRow()
                }
                .onAppear {
                    // Открываемся на текущем месяце; если месяц один, он просто остаётся сверху
                    if months.count > 1, let last = months.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
        }
        .navigationTitle(habit.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Изменить") { editing = habit }
            }
        }
    }
}
