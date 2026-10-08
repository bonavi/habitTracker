// Генерирует иконку приложения: swift Scripts/generate-app-icon.swift habitTracker/Assets.xcassets/AppIcon.appiconset
import AppKit
import CoreGraphics

enum Variant { case light, dark, tinted }

func render(_ v: Variant, to path: String) {
    let size = 1024
    let cs = CGColorSpaceCreateDeviceRGB()
    let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    let full = CGRect(x: 0, y: 0, width: size, height: size)
    let blue = CGColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1)

    // Фон
    switch v {
    case .light:
        let g = CGGradient(colorsSpace: cs, colors: [
            CGColor(red: 1, green: 1, blue: 1, alpha: 1),
            CGColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 0, y: 0), options: [])
    case .dark:
        let g = CGGradient(colorsSpace: cs, colors: [
            CGColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1),
            CGColor(red: 0.03, green: 0.03, blue: 0.05, alpha: 1)] as CFArray, locations: [0, 1])!
        ctx.drawLinearGradient(g, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 0, y: 0), options: [])
    case .tinted:
        ctx.setFillColor(CGColor(gray: 0, alpha: 1)); ctx.fill(full)
    }

    // Ячейка — скруглённый квадрат
    let side: CGFloat = 600
    let cell = CGRect(x: (1024 - side) / 2, y: (1024 - side) / 2, width: side, height: side)
    let cellPath = CGPath(roundedRect: cell, cornerWidth: 150, cornerHeight: 150, transform: nil)
    let fill: CGColor = v == .tinted ? CGColor(gray: 1, alpha: 1) : blue
    let empty: CGColor = {
        switch v {
        case .light: return CGColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 0.18)
        case .dark: return CGColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 0.28)
        case .tinted: return CGColor(gray: 1, alpha: 0.3)
        }
    }()

    ctx.saveGState()
    ctx.addPath(cellPath); ctx.clip()
    ctx.setFillColor(empty); ctx.fill(cell)

    // 2 из 3 секторов, от верха по часовой (в CG ось Y вверх → по часовой = убывание угла)
    let c = CGPoint(x: 512, y: 512), r: CGFloat = 600
    let start = CGFloat.pi / 2
    let sector = CGMutablePath()
    sector.move(to: c)
    sector.addArc(center: c, radius: r, startAngle: start, endAngle: start - 2 * .pi * 2 / 3, clockwise: true)
    sector.closeSubpath()
    ctx.addPath(sector); ctx.setFillColor(fill); ctx.fillPath()

    // Разделители — вырезаем прозрачностью/цветом фона
    ctx.setBlendMode(.clear)
    ctx.setLineWidth(26); ctx.setLineCap(.butt)
    for i in 0..<3 {
        let a = start - 2 * .pi * CGFloat(i) / 3
        ctx.move(to: c); ctx.addLine(to: CGPoint(x: c.x + r * cos(a), y: c.y + r * sin(a)))
    }
    ctx.strokePath()
    ctx.restoreGState()

    // Под вырезанными линиями проявляем фон обратно (иконки iOS без прозрачности)
    let img = ctx.makeImage()!
    let out = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                        space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    switch v {
    case .light:
        let g = CGGradient(colorsSpace: cs, colors: [
            CGColor(red: 1, green: 1, blue: 1, alpha: 1),
            CGColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)] as CFArray, locations: [0, 1])!
        out.drawLinearGradient(g, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 0, y: 0), options: [])
    case .dark:
        let g = CGGradient(colorsSpace: cs, colors: [
            CGColor(red: 0.12, green: 0.13, blue: 0.16, alpha: 1),
            CGColor(red: 0.03, green: 0.03, blue: 0.05, alpha: 1)] as CFArray, locations: [0, 1])!
        out.drawLinearGradient(g, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 0, y: 0), options: [])
    case .tinted:
        out.setFillColor(CGColor(gray: 0, alpha: 1)); out.fill(full)
    }
    out.draw(img, in: full)

    let rep = NSBitmapImageRep(cgImage: out.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

let dir = CommandLine.arguments[1]
render(.light, to: dir + "/AppIcon.png")
render(.dark, to: dir + "/AppIcon-dark.png")
render(.tinted, to: dir + "/AppIcon-tinted.png")
