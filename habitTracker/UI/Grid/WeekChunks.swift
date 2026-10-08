import Foundation

/// Делит дни (начиная с первого дня недели) на недели по 7 дней.
func weekChunks(_ days: [Date]) -> [[Date]] {
    stride(from: 0, to: days.count, by: 7).map { Array(days[$0..<min($0 + 7, days.count)]) }
}
