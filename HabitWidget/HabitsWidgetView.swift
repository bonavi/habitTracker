import SwiftUI
import WidgetKit

struct HabitsWidgetView: View {
    let entry: HabitsEntry
    @Environment(\.widgetFamily) private var family

    /// Сколько привычек влезает в виджет данного размера.
    private var maxRows: Int {
        switch family {
        case .systemSmall: 4
        case .systemMedium: 4
        default: 10
        }
    }

    private var showsWeek: Bool { family != .systemSmall }

    var body: some View {
        if entry.rows.isEmpty {
            if entry.hasHabits {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text("Всё выполнено на сегодня")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                Text("Добавьте привычку в приложении")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        } else {
            VStack(spacing: 0) {
                if showsWeek {
                    HabitWidgetHeader(days: entry.days, today: entry.today, startDate: entry.startDate)
                    Spacer(minLength: 2)
                }
                ForEach(entry.rows.prefix(maxRows)) { row in
                    HabitWidgetRowView(
                        row: row,
                        days: showsWeek ? entry.days : [entry.today],
                        today: entry.today,
                        startDate: entry.startDate,
                        isCompact: !showsWeek
                    )
                    .frame(maxHeight: 30)
                    Spacer(minLength: 0)
                }
            }
        }
    }
}
