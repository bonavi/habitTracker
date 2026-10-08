import Foundation

/// Период, за который считается цель привычки.
enum GoalPeriod: String, Codable, CaseIterable, Identifiable, Sendable {
    case none
    case day
    case week
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: "Без цели"
        case .day: "В день"
        case .week: "В неделю"
        case .month: "В месяц"
        }
    }

    var shortSuffix: String {
        switch self {
        case .none, .day: ""
        case .week: "нед."
        case .month: "мес."
        }
    }
}
