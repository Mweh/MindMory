enum HomeCardState: String, CaseIterable, Identifiable {
    case normal
    case firstReminderPrepared
    case photoAccessDenied

    var id: String { rawValue }

    var title: String {
        switch self {
        case .normal:
            return "Normal Memory Card"
        case .firstReminderPrepared:
            return "First Reminder Prepared"
        case .photoAccessDenied:
            return "Photo Access Not Allowed"
        }
    }
}
