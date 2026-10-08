import SwiftUI

struct HabitNameCell: View {
    let habit: Habit
    let progress: PeriodProgress?
    let onOpen: () -> Void
    let onEdit: () -> Void
    let onArchive: () -> Void
    let onDelete: () -> Void
    /// В одну строку (название · прогресс) — для двустрочной раскладки на iPhone.
    var isInline = false

    @State private var confirmDelete = false

    var body: some View {
        Button(action: onOpen) {
            let layout = isInline
                ? AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 6))
                : AnyLayout(VStackLayout(alignment: .leading, spacing: 2))
            layout {
                Text(habit.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(isInline ? 1 : 2)
                if let progress {
                    Text("\(progress.done)/\(progress.goal) · \(habit.goalPeriod.shortSuffix)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(progress.done >= progress.goal ? HabitColor.color(habit.colorIndex) : .secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Изменить", systemImage: "pencil", action: onEdit)
            Button("В архив", systemImage: "archivebox", action: onArchive)
            Button("Удалить", systemImage: "trash", role: .destructive) { confirmDelete = true }
        }
        .confirmationDialog("Удалить «\(habit.name)»?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Удалить", role: .destructive, action: onDelete)
        } message: {
            Text("Все отметки этой привычки тоже будут удалены.")
        }
    }
}
