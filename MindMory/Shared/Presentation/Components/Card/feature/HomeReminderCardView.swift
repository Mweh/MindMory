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
                .font(MindMoryTypography.titleMedium)
                .foregroundStyle(MindMoryColors.Content.primary)

            Text(reminder.message)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)

            Text(contextText)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Surface.primary)
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

#if DEBUG
struct HomeReminderCardView_Previews: PreviewProvider {
    static var previews: some View {
        HomeReminderCardView(reminder: PreviewData.reminder)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    HomeReminderCardView(reminder: PreviewData.reminder)
        .padding()
        .background(MindMoryColors.Surface.background)
}
