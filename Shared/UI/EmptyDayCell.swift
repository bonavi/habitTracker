import SwiftUI

/// Пустой пунктирный квадрат — день, который нельзя отметить (будущий или до начала истории).
struct EmptyDayCell: View {
    var cornerRadius: CGFloat = 9

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(Color(.quaternaryLabel), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
    }
}
