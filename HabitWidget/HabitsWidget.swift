import SwiftUI
import WidgetKit

struct HabitsWidget: Widget {
    static let kind = "HabitsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: Self.kind, intent: SelectHabitsIntent.self, provider: HabitsProvider()) { entry in
            HabitsWidgetView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Привычки")
        .description("Отмечайте выполнение привычек прямо с экрана «Домой».")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
