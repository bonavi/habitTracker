import SwiftUI

/// Форма создания/редактирования в стилистике Reminders.
struct HabitEditorSheet: View {
    let onSave: (Habit) -> Void
    private let isNew: Bool
    @State private var draft: Habit
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameFocused: Bool

    init(habit: Habit?, onSave: @escaping (Habit) -> Void) {
        self.onSave = onSave
        self.isNew = habit == nil
        _draft = State(initialValue: habit ?? Habit(name: "", colorIndex: Int.random(in: 0..<HabitColor.palette.count)))
    }

    private var trimmedName: String { draft.name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 16) {
                        HabitBadge(name: trimmedName, color: HabitColor.color(draft.colorIndex))
                        TextField("Название", text: $draft.name)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(HabitColor.color(draft.colorIndex))
                            .padding(.vertical, 12)
                            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .focused($nameFocused)
                            .submitLabel(.done)
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    ColorGrid(selection: $draft.colorIndex)
                }

                Section {
                    Picker("Цель", selection: $draft.goalPeriod) {
                        ForEach(GoalPeriod.allCases) { Text($0.title).tag($0) }
                    }
                    if draft.goalPeriod != .none {
                        Stepper(value: goalValue, in: 1...99) {
                            LabeledContent("Количество", value: "\(goalValue.wrappedValue)")
                        }
                    }
                    if draft.goalPeriod == .week || draft.goalPeriod == .month {
                        Picker("Считать", selection: $draft.countMode) {
                            ForEach(CountMode.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                } footer: {
                    Text(goalFooter)
                }
            }
            .navigationTitle(isNew ? "Новая привычка" : "Привычка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        var habit = draft
                        habit.name = trimmedName
                        if habit.goalPeriod == .none { habit.goalValue = nil }
                        onSave(habit)
                        dismiss()
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear { if isNew { nameFocused = true } }
        }
    }

    private var goalValue: Binding<Int> {
        Binding(get: { draft.goalValue ?? 1 }, set: { draft.goalValue = $0 })
    }

    private var goalFooter: String {
        switch draft.goalPeriod {
        case .none: "Просто отмечайте выполнения — квадрат заливается при первом тапе."
        case .day: "Квадрат дня делится на секторы по числу выполнений в цели."
        case .week, .month:
            draft.countMode == .sum
                ? "Считается сумма всех выполнений за период."
                : "Считается число дней хотя бы с одним выполнением."
        }
    }
}
