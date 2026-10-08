import SwiftUI

struct DayHeader: View {
    let day: Date
    let isToday: Bool

    var body: some View {
        VStack(spacing: 1) {
            Text(day, format: .dateTime.weekday(.short))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(day, format: .dateTime.day())
                .font(.caption.weight(isToday ? .bold : .regular))
                .foregroundStyle(isToday ? Color.accentColor : .primary)
        }
    }
}
