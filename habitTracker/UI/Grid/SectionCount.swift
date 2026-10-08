import Foundation

/// Количество привычек в разделе — для счётчика в заголовке.
func sectionCount(_ kind: HabitSectionKind, in rows: [HabitGridRow]) -> Int {
    var current: HabitSectionKind?
    var count = 0
    for row in rows {
        switch row {
        case .header(let k): current = k
        case .habit: if current == kind { count += 1 }
        }
    }
    return count
}
