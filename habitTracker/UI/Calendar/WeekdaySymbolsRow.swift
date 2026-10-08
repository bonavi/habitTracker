import SwiftUI

/// Закреплённая строка с днями недели над календарём.
struct WeekdaySymbolsRow: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(MonthGrid.weekdaySymbols().enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(.bar)
    }
}
