import SwiftUI

struct ReorderSheet: View {
    @State var habits: [Habit]
    let onSave: ([UUID]) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    Label {
                        Text(habit.name)
                    } icon: {
                        Circle().fill(HabitColor.color(habit.colorIndex)).frame(width: 12, height: 12)
                    }
                }
                .onMove { habits.move(fromOffsets: $0, toOffset: $1) }
            }
            .environment(\.editMode, .constant(.active))
            .navigationTitle("Порядок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        onSave(habits.map(\.id))
                        dismiss()
                    }
                }
            }
        }
    }
}
