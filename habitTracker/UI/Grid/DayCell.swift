import SwiftUI

/// Интерактивный квадрат дня: тап — +1, удержание — −1.
struct DayCell: View {
    let count: Int
    let dailyGoal: Int?
    let color: Color
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        DayCellContent(count: count, dailyGoal: dailyGoal, color: color)
            // Эксклюзивно: удержание (−1) имеет приоритет, иначе срабатывает тап (+1)
            .gesture(
                LongPressGesture(minimumDuration: 0.3)
                    .onEnded { _ in onDecrement() }
                    .exclusively(before: TapGesture().onEnded(onIncrement))
            )
            .sensoryFeedback(.increase, trigger: count) { old, new in new > old }
            .sensoryFeedback(.decrease, trigger: count) { old, new in new < old }
            .animation(.snappy(duration: 0.2), value: count)
    }
}
