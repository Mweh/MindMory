import SwiftUI

struct HomeReminderCardView: View {

    let reminder: Reminder

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: MindMorySpacing.md) {
                IconBadgeView(systemName: "bell.badge.fill")

                contentSection

                Spacer()
            }
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(reminder.title)
                .font(MindMoryTypography.headingMedium)
                .foregroundStyle(MindMoryColors.textPrimary)

            Text(reminder.message)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text(contextText)
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
    }

    private var contextText: String {
        switch reminder.context {
        case .location(let location):
            return location.placeName + " · " + location.durationText

        case .publicHoliday(let holiday):
            return holiday.name + " · " + holiday.dateText

        case .event(let event):
            return event.title + " · " + event.timeText

        case .locationAndHoliday(let location, let holiday):
            return location.placeName + " · " + holiday.name

        case .none:
            return "MindMory"
        }
    }
}
