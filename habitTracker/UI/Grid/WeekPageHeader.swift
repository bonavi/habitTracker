import SwiftUI

/// Строка над днями недели: номер недели слева, месяц справа.
struct WeekPageHeader: View {
    let title: String
    let months: String

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text(title)
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            Text(months)
                .foregroundStyle(.primary)
        }
        .font(.caption.weight(.semibold))
        .lineLimit(1)
        .padding(.horizontal, 6)
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}
