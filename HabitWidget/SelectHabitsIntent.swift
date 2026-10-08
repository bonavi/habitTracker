import AppIntents
import WidgetKit

/// Настройка виджета: какие привычки показывать. Пусто — все.
struct SelectHabitsIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Привычки"
    static let description = IntentDescription("Выберите привычки для виджета. Если ничего не выбрано, показываются все.")

    @Parameter(title: "Привычки")
    var habits: [HabitEntity]?
}
