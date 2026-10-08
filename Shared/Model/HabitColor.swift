import SwiftUI

enum HabitColor {
    static let palette: [Color] = [
        .red, .orange, .yellow, .green, .mint, .teal, .blue, .indigo, .purple, .pink, .brown, .gray
    ]

    static func color(_ index: Int) -> Color {
        palette[((index % palette.count) + palette.count) % palette.count]
    }
}
