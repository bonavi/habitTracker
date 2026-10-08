import SwiftUI

struct SettingsScreen: View {
    let viewModel: HabitsViewModel

    private var isStartDateEnabled: Binding<Bool> {
        Binding(
            get: { viewModel.startDate != nil },
            set: { viewModel.setStartDate($0 ? Date() : nil) }
        )
    }

    private var startDate: Binding<Date> {
        Binding(
            get: { viewModel.startDate ?? Date() },
            set: { viewModel.setStartDate($0) }
        )
    }

    var body: some View {
        Form {
            Section {
                Toggle("Начало отсчёта", isOn: isStartDateEnabled.animation())
                if viewModel.startDate != nil {
                    DatePicker("Дата", selection: startDate, in: ...Date(), displayedComponents: .date)
                }
            } footer: {
                Text("Дни до этой даты не показываются в таблице. Отметки при этом сохраняются.")
            }

            Section {
                Toggle("Разделы «Осталось» и «Готово»", isOn: Binding(
                    get: { viewModel.snapshot.groupByDone },
                    set: { viewModel.setGroupByDone($0) }
                ))
            } footer: {
                Text("Привычки, выполненные сегодня, автоматически переезжают вниз в раздел «Готово». Для недельной и месячной цели привычка готова, если цель периода уже выполнена или есть отметка сегодня.")
            }
        }
        .navigationTitle("Настройки")
    }
}
