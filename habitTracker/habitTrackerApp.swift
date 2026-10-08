import GRDB
import SwiftUI

@main
struct habitTrackerApp: App {
    private let database: AppDatabase
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            database = try AppDatabase.makeShared()
        } catch {
            fatalError("Не удалось открыть базу данных: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HabitsScreen(viewModel: HabitsViewModel(database: database, archived: false))
        }
        .onChange(of: scenePhase) { _, phase in
            // База лежит в общем контейнере: в фоне отпускаем блокировки, при возврате — снова работаем
            switch phase {
            case .background: NotificationCenter.default.post(name: Database.suspendNotification, object: nil)
            case .active: NotificationCenter.default.post(name: Database.resumeNotification, object: nil)
            default: break
            }
        }
    }
}
