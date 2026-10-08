import SwiftUI

/// Строка дней недели над квадратами в среднем и большом виджете.
struct HabitWidgetHeader: View {
    let days: [Date]
    let today: Date
    var startDate: Date?

    var body: some View {
        HStack(spacing: HabitWidgetRowView.cellSpacing) {
            Spacer(minLength: 0)
            ForEach(days, id: \.self) { day in
                Text(day, format: .dateTime.weekday(.short))
                    .font(.system(size: 9, weight: day == today ? .bold : .regular))
                    .foregroundStyle(day == today ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.secondary))
                    .frame(width: HabitWidgetRowView.cellSize)
                    .opacity(day > today || (startDate.map { day < $0 } ?? false) ? 0.4 : 1)
            }
        }
    }
}
