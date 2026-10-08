import Foundation

/// Что считается в прогрессе недельной/месячной цели.
enum CountMode: String, Codable, CaseIterable, Identifiable, Sendable {
    /// Сумма всех выполнений за период.
    case sum
    /// Количество дней, в которые было хотя бы одно выполнение.
    case days

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sum: "Сумма"
        case .days: "Дни"
        }
    }
}
