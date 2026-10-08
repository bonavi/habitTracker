import WidgetKit

struct HabitsProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitsEntry {
        .placeholder()
    }

    func snapshot(for configuration: SelectHabitsIntent, in context: Context) async -> HabitsEntry {
        context.isPreview ? .placeholder() : makeEntry(configuration)
    }

    func timeline(for configuration: SelectHabitsIntent, in context: Context) async -> Timeline<HabitsEntry> {
        let entry = makeEntry(configuration)
        // Следующее обновление — в полночь, чтобы «сегодня» сдвинулось
        let midnight = Calendar.current.date(byAdding: .day, value: 1, to: entry.today) ?? entry.today
        return Timeline(entries: [entry], policy: .after(midnight))
    }

    private func makeEntry(_ configuration: SelectHabitsIntent) -> HabitsEntry {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        // Текущая неделя целиком (по локали): прошлые дни, сегодня и будущие до конца недели
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let days = ProgressCalculator.days(
            from: weekStart,
            to: ProgressCalculator.endOfWeek(for: today, calendar: calendar),
            calendar: calendar
        )

        guard let snapshot = try? WidgetDatabase.shared?.snapshot(archived: false) else {
            return HabitsEntry(date: now, today: today, days: days, rows: [], startDate: nil)
        }

        // Порядок — как в приложении; фильтр — по выбранным в настройках виджета
        let selected = Set((configuration.habits ?? []).map(\.id))
        let habits = selected.isEmpty ? snapshot.habits : snapshot.habits.filter { selected.contains($0.id) }

        // Выполненные сегодня привычки в виджете не показываем
        let rows = habits.compactMap { habit -> HabitWidgetRow? in
            let counts = snapshot.counts[habit.id] ?? [:]
            if HabitStatus.isDoneToday(habit, counts: counts, today: today, calendar: calendar) { return nil }
            return HabitWidgetRow(
                habit: habit,
                counts: counts,
                progress: ProgressCalculator.progress(for: habit, counts: counts, today: today, calendar: calendar)
            )
        }
        let startDate = snapshot.startDay.flatMap { DayKey.date(from: $0, calendar: calendar) }
        return HabitsEntry(
            date: now, today: today, days: days, rows: rows, startDate: startDate, hasHabits: !habits.isEmpty
        )
    }
}
