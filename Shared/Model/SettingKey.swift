import Foundation

/// Ключи строк в таблице `setting`.
enum SettingKey: String {
    /// День начала отсчёта (`yyyy-MM-dd`). Дни до него не показываются в таблице.
    case startDay
    /// `1` — делить привычки на главном экране на разделы «Осталось» и «Готово».
    case groupByDone
}
