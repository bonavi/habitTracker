import AppIntents

/// Привычка для выбора в настройках виджета.
struct HabitEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Привычка"
    static let defaultQuery = HabitEntityQuery()

    let id: UUID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}
