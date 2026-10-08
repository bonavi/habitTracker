import Foundation
import GRDB
import OSLog

private let logger = Logger(subsystem: "habitTracker", category: "Database")

/// Снимок данных для главного экрана: привычки и их выполнения по дням.
struct HabitsSnapshot: Sendable, Equatable {
    var habits: [Habit] = []
    /// habitId -> (день -> количество)
    var counts: [UUID: [String: Int]] = [:]
    /// День начала отсчёта из настроек (`yyyy-MM-dd`).
    var startDay: String?
    /// Делить главный экран на разделы «Осталось» / «Готово».
    var groupByDone = false
}

struct AppDatabase: Sendable {
    private let writer: any DatabaseWriter

    init(_ writer: any DatabaseWriter) throws {
        self.writer = writer
        try Self.migrator.migrate(writer)
    }

    /// База в общем контейнере App Group — её читает и пишет и приложение, и виджет.
    static func makeShared() throws -> AppDatabase {
        let fileManager = FileManager()
        let url = try sharedDatabaseURL(fileManager)
        logger.info("Database stored at \(url.path)")

        var config = Configuration()
        // Не держим блокировки файла в общем контейнере, пока приложение в фоне (иначе 0xdead10cc)
        config.observesSuspensionNotifications = true
        return try AppDatabase(DatabasePool(path: url.path, configuration: config))
    }

    private static func sharedDatabaseURL(_ fileManager: FileManager) throws -> URL {
        let legacyDirectory = try fileManager
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("database", isDirectory: true)

        guard let container = AppGroup.containerURL else {
            // Без App Group (например, нет entitlement) — работаем по-старому
            logger.error("App Group container unavailable, using legacy location")
            try fileManager.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
            return legacyDirectory.appendingPathComponent("db.sqlite")
        }

        let directory = container.appendingPathComponent("database", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appendingPathComponent("db.sqlite")

        // Одноразовый перенос базы из контейнера приложения (версии до виджета)
        let legacyURL = legacyDirectory.appendingPathComponent("db.sqlite")
        if !fileManager.fileExists(atPath: url.path), fileManager.fileExists(atPath: legacyURL.path) {
            do {
                for suffix in ["", "-wal", "-shm"] {
                    let from = URL(fileURLWithPath: legacyURL.path + suffix)
                    guard fileManager.fileExists(atPath: from.path) else { continue }
                    try fileManager.moveItem(at: from, to: URL(fileURLWithPath: url.path + suffix))
                }
                logger.info("Database migrated to App Group container")
            } catch {
                logger.error("Database migration failed, using legacy location: \(error)")
                return legacyURL
            }
        }
        return url
    }

    static func makeInMemory() throws -> AppDatabase {
        try AppDatabase(DatabaseQueue())
    }

    // MARK: - Наблюдение

    func observeSnapshot(archived: Bool) -> AsyncValueObservation<HabitsSnapshot> {
        ValueObservation.tracking { db in try Self.fetchSnapshot(db, archived: archived) }
            .values(in: writer)
    }

    func snapshot(archived: Bool) throws -> HabitsSnapshot {
        try writer.read { db in try Self.fetchSnapshot(db, archived: archived) }
    }

    private static func fetchSnapshot(_ db: Database, archived: Bool) throws -> HabitsSnapshot {
        let habits = try Habit
            .filter(Column("deletedAt") == nil && Column("isArchived") == archived)
            .order(Column("sortOrder"), Column("createdAt"))
            .fetchAll(db)
        let entries = try HabitEntry
            .filter(Column("deletedAt") == nil && Column("count") > 0)
            .fetchAll(db)
        var counts: [UUID: [String: Int]] = [:]
        for entry in entries {
            counts[entry.habitId, default: [:]][entry.day] = entry.count
        }
        let startDay = try setting(db, .startDay)
        let groupByDone = try setting(db, .groupByDone) == "1"
        return HabitsSnapshot(habits: habits, counts: counts, startDay: startDay, groupByDone: groupByDone)
    }

    private static func setting(_ db: Database, _ key: SettingKey) throws -> String? {
        try String.fetchOne(
            db,
            sql: "SELECT value FROM setting WHERE key = ? AND deletedAt IS NULL",
            arguments: [key.rawValue]
        )
    }

    // MARK: - Привычки

    func save(_ habit: Habit) throws {
        try writer.write { db in
            var habit = habit
            habit.updatedAt = Date()
            if try Habit.exists(db, key: habit.id) == false {
                let maxOrder = try Int.fetchOne(db, sql: "SELECT MAX(sortOrder) FROM habit") ?? -1
                habit.sortOrder = maxOrder + 1
            }
            try habit.save(db)
        }
    }

    func setArchived(_ id: UUID, _ archived: Bool) throws {
        try writer.write { db in
            try db.execute(
                sql: "UPDATE habit SET isArchived = ?, updatedAt = ? WHERE id = ?",
                arguments: [archived, Date(), id]
            )
        }
    }

    /// Мягкое удаление — запись остаётся для будущей синхронизации.
    func delete(_ id: UUID) throws {
        try writer.write { db in
            let now = Date()
            try db.execute(sql: "UPDATE habit SET deletedAt = ?, updatedAt = ? WHERE id = ?", arguments: [now, now, id])
            try db.execute(sql: "UPDATE habitEntry SET deletedAt = ?, updatedAt = ? WHERE habitId = ?", arguments: [now, now, id])
        }
    }

    func reorder(_ ids: [UUID]) throws {
        try writer.write { db in
            let now = Date()
            for (index, id) in ids.enumerated() {
                try db.execute(
                    sql: "UPDATE habit SET sortOrder = ?, updatedAt = ? WHERE id = ?",
                    arguments: [index, now, id]
                )
            }
        }
    }

    // MARK: - Выполнения

    /// Меняет количество выполнений за день на `delta`, не опускаясь ниже нуля.
    func changeCount(habitId: UUID, day: String, by delta: Int) throws {
        try writer.write { db in
            let now = Date()
            try db.execute(
                sql: """
                INSERT INTO habitEntry (id, habitId, day, count, updatedAt, deletedAt)
                VALUES (?, ?, ?, MAX(0, ?), ?, NULL)
                ON CONFLICT(habitId, day) DO UPDATE SET
                    count = MAX(0, CASE WHEN deletedAt IS NULL THEN count ELSE 0 END + ?),
                    updatedAt = excluded.updatedAt,
                    deletedAt = NULL
                """,
                arguments: [UUID(), habitId, day, delta, now, delta]
            )
        }
    }

    // MARK: - Настройки

    /// Записывает настройку; `nil` — мягко удаляет её.
    func setSetting(_ key: SettingKey, _ value: String?) throws {
        try writer.write { db in
            let now = Date()
            try db.execute(
                sql: """
                INSERT INTO setting (key, value, updatedAt, deletedAt) VALUES (?, ?, ?, ?)
                ON CONFLICT(key) DO UPDATE SET
                    value = excluded.value,
                    updatedAt = excluded.updatedAt,
                    deletedAt = excluded.deletedAt
                """,
                arguments: [key.rawValue, value, now, value == nil ? now : nil]
            )
        }
    }

    // MARK: - Миграции

    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1") { db in
            try db.create(table: "habit") { t in
                t.primaryKey("id", .blob)
                t.column("name", .text).notNull()
                t.column("colorIndex", .integer).notNull()
                t.column("sortOrder", .integer).notNull()
                t.column("goalPeriod", .text).notNull()
                t.column("goalValue", .integer)
                t.column("countMode", .text).notNull()
                t.column("isArchived", .boolean).notNull().defaults(to: false)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("deletedAt", .datetime)
            }
            try db.create(table: "habitEntry") { t in
                t.primaryKey("id", .blob)
                t.belongsTo("habit", onDelete: .cascade).notNull()
                t.column("day", .text).notNull()
                t.column("count", .integer).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("deletedAt", .datetime)
                t.uniqueKey(["habitId", "day"])
            }
        }

        migrator.registerMigration("v2_settings") { db in
            try db.create(table: "setting") { t in
                t.primaryKey("key", .text)
                t.column("value", .text)
                t.column("updatedAt", .datetime).notNull()
                t.column("deletedAt", .datetime)
            }
        }

        return migrator
    }
}
