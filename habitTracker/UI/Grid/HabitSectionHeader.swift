import SwiftUI

/// Разделитель перед разделом: тонкая линия на всю ширину с маленькой плашкой.
struct HabitSectionHeader: View {
    let kind: HabitSectionKind
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .bold))
                Text("\(kind.title) \(count)")
                    .font(.caption2.weight(.semibold))
                    .monospacedDigit()
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(.quaternary))

            Rectangle()
                .fill(.separator)
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 2)
    }
}
