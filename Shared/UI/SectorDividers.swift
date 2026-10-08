import SwiftUI

/// Линии-разделители между секторами, от центра к краю.
struct SectorDividers: Shape {
    let sectors: Int

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = hypot(rect.width, rect.height)
        var path = Path()
        for index in 0..<sectors {
            let angle = (-90 + 360 * Double(index) / Double(sectors)) * .pi / 180
            path.move(to: center)
            path.addLine(to: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
        }
        return path
    }
}
