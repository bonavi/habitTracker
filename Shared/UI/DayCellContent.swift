import SwiftUI
import WidgetKit

/// Внешний вид скруглённого квадрата дня, без жестов — общий для приложения и виджета.
/// При дневной цели заполняется секторами, иначе — целиком.
struct DayCellContent: View {
    let count: Int
    let dailyGoal: Int?
    let color: Color
    var cornerRadius: CGFloat = 9
    /// Бейдж «+N» сверх дневной цели; на мелких квадратах виджета он налезает на соседние строки.
    var showsOverflowBadge = true

    /// Больше этого числа секторы не разделяются линиями — заливка идёт сплошной «пиццей».
    private static let maxVisibleSectors = 8

    /// В tinted/clear-режиме виджета все цвета перекрашиваются в один,
    /// поэтому разделители и цифры не рисуем поверх, а вырезаем из заливки.
    @Environment(\.widgetRenderingMode) private var renderingMode
    private var isKnockout: Bool { renderingMode != .fullColor }
    private var shape: RoundedRectangle { RoundedRectangle(cornerRadius: cornerRadius, style: .continuous) }

    var body: some View {
        ZStack {
            shape.fill(color.opacity(0.15))
            fill
            label
        }
        .compositingGroup()
        .clipShape(shape)
        .overlay(alignment: .topTrailing) { overflowBadge }
        .contentShape(shape)
    }

    @ViewBuilder
    private var fill: some View {
        if let goal = dailyGoal, goal > 1 {
            let filled = min(count, goal)
            SectorShape(fraction: Double(filled) / Double(goal))
                .fill(color)
            if goal <= Self.maxVisibleSectors {
                SectorDividers(sectors: goal)
                    .stroke(isKnockout ? Color.black : Color(.systemBackground), lineWidth: 1.5)
                    .blendMode(isKnockout ? .destinationOut : .normal)
            }
        } else if count > 0 {
            shape.fill(color)
        }
    }

    @ViewBuilder
    private var label: some View {
        if dailyGoal == nil, count > 1 {
            Text("\(count)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(isKnockout ? Color.black : .white)
                .blendMode(isKnockout ? .destinationOut : .normal)
        }
    }

    @ViewBuilder
    private var overflowBadge: some View {
        if showsOverflowBadge, let goal = dailyGoal, count > goal {
            Text("+\(count - goal)")
                .font(.system(size: 9, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.horizontal, 3)
                .background(Capsule().fill(color).stroke(Color(.systemBackground), lineWidth: 1.5))
                .offset(x: 6, y: -6)
        }
    }
}
