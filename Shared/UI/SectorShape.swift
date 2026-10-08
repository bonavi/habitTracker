import SwiftUI

/// Сектор из центра, начиная сверху по часовой стрелке. Выходит за границы, обрезается формой ячейки.
struct SectorShape: Shape {
    var fraction: Double

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func path(in rect: CGRect) -> Path {
        guard fraction > 0 else { return Path() }
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = hypot(rect.width, rect.height)
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(-90 + 360 * min(fraction, 1)),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}
