import SwiftUI

/// Большой цветной кружок с первой буквой — как иконка списка в Reminders.
struct HabitBadge: View {
    let name: String
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(color.gradient)
                .shadow(color: color.opacity(0.4), radius: 8, y: 4)
            if let letter = name.first {
                Text(String(letter).uppercased())
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 88, height: 88)
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: color)
    }
}
