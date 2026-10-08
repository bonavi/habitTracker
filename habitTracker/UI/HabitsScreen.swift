import SwiftUI

struct HabitsScreen: View {
    @State var viewModel: HabitsViewModel
    @State private var editing: Habit?
    @State private var openedHabitId: UUID?
    @State private var isCreating = false
    @State private var isReordering = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.snapshot.habits.isEmpty {
                    ContentUnavailableView {
                        Label("Нет привычек", systemImage: "square.grid.3x3")
                    } actions: {
                        Button("Создать привычку") { isCreating = true }
                    }
                } else {
                    HabitGridView(
                        viewModel: viewModel,
                        onOpen: { openedHabitId = $0.id },
                        onEdit: { editing = $0 }
                    )
                }
            }
            .navigationTitle("Привычки")
            .navigationDestination(item: $openedHabitId) { id in
                HabitCalendarScreen(viewModel: viewModel, habitId: id)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        NavigationLink {
                            ArchiveScreen(viewModel: HabitsViewModel(database: viewModel.database, archived: true))
                        } label: {
                            Label("Архив", systemImage: "archivebox")
                        }
                        Button {
                            isReordering = true
                        } label: {
                            Label("Изменить порядок", systemImage: "arrow.up.arrow.down")
                        }
                        .disabled(viewModel.snapshot.habits.count < 2)
                        NavigationLink {
                            SettingsScreen(viewModel: viewModel)
                        } label: {
                            Label("Настройки", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { isCreating = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $isCreating) {
                HabitEditorSheet(habit: nil) { viewModel.save($0) }
            }
            .sheet(item: $editing) { habit in
                HabitEditorSheet(habit: habit) { viewModel.save($0) }
            }
            .sheet(isPresented: $isReordering) {
                ReorderSheet(habits: viewModel.snapshot.habits) { viewModel.reorder($0) }
            }
        }
        // Перезапуск наблюдения при возврате в приложение подхватывает отметки, сделанные в виджете
        .task(id: scenePhase == .active) { await viewModel.observe() }
        .onOpenURL { url in
            if let id = WidgetLink.habitId(from: url) { openedHabitId = id }
        }
    }
}
