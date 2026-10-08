import SwiftUI

struct ArchiveScreen: View {
    @State var viewModel: HabitsViewModel
    @State private var pendingDelete: Habit?

    var body: some View {
        List {
            ForEach(viewModel.snapshot.habits) { habit in
                Label {
                    Text(habit.name)
                } icon: {
                    Circle().fill(HabitColor.color(habit.colorIndex)).frame(width: 12, height: 12)
                }
                .swipeActions(edge: .trailing) {
                    Button("Удалить", systemImage: "trash", role: .destructive) { pendingDelete = habit }
                }
                .swipeActions(edge: .leading) {
                    Button("Вернуть", systemImage: "arrow.uturn.backward") { viewModel.setArchived(habit, false) }
                        .tint(.blue)
                }
                .contextMenu {
                    Button("Вернуть", systemImage: "arrow.uturn.backward") { viewModel.setArchived(habit, false) }
                    Button("Удалить", systemImage: "trash", role: .destructive) { pendingDelete = habit }
                }
            }
        }
        .overlay {
            if viewModel.snapshot.habits.isEmpty {
                ContentUnavailableView("Архив пуст", systemImage: "archivebox")
            }
        }
        .navigationTitle("Архив")
        .confirmationDialog(
            "Удалить «\(pendingDelete?.name ?? "")»?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Удалить", role: .destructive) {
                if let habit = pendingDelete { viewModel.delete(habit) }
            }
        }
        .task { await viewModel.observe() }
    }
}
