enum HomeCardState: String, CaseIterable, Identifiable {
    case normal
    case firstReminderPrepared

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal:
            return "Normal Memory Card"
        case .firstReminderPrepared:
            return "First Reminder Prepared"
        }
    }
}
