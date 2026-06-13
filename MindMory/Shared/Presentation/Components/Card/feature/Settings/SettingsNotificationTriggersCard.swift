import SwiftUI

struct SettingsNotificationTriggersCard: View {
    @ObservedObject var viewModel: ContextualTriggersViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                titleSection
                triggerTogglesSection
                wordingPreferenceSection
                saveButton
            }
            .toggleStyle(
                SwitchToggleStyle(tint: MindMoryColors.Surface.primary)
            )
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text("Contextual triggers")
                .font(MindMoryTypography.titleMedium)

            Text("Turn on which kinds of location and moment triggers should create reminders.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    private var triggerTogglesSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Toggle("Location-based reminders", isOn: $viewModel.settings.locationBasedReminders)
            Toggle("Public holiday reminders", isOn: $viewModel.settings.publicHolidayReminders)
            Toggle("Calendar/EventKit reminders", isOn: $viewModel.settings.calendarReminders)
            Toggle("User pattern / schedule", isOn: $viewModel.settings.userPatternReminders)
            Toggle("Recent activity", isOn: $viewModel.settings.recentActivityReminders)
        }
    }

    private var wordingPreferenceSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text("Notification wording preference")
                .font(MindMoryTypography.bodySmall)

            Text(viewModel.settings.notificationWordingPreference)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Surface.primary)
        }
    }

    private var saveButton: some View {
        Button(action: viewModel.save) {
            Text("Save changes")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
    }
}

#if DEBUG
struct SettingsNotificationTriggersCard_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationTriggersCard(viewModel: ContextualTriggersViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
