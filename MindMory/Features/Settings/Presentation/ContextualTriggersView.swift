import SwiftUI

struct ContextualTriggersView: View {

    @ObservedObject var viewModel: ContextualTriggersViewModel

    var body: some View {
        SettingsNotificationTriggersCard(viewModel: viewModel)
    }

    private var titleSection: some View {
        Text("Contextual Triggers")
            .font(MindMoryTypography.titleMedium)
    }

    private var triggerTogglesSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Toggle(
                "Location-based reminders",
                isOn: $viewModel.settings.locationBasedReminders
            )

            Toggle(
                "Public holiday reminders",
                isOn: $viewModel.settings.publicHolidayReminders
            )

            Toggle(
                "Calendar/EventKit reminders",
                isOn: $viewModel.settings.calendarReminders
            )

            Toggle(
                "User pattern / schedule",
                isOn: $viewModel.settings.userPatternReminders
            )

            Toggle(
                "Recent activity",
                isOn: $viewModel.settings.recentActivityReminders
            )
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
        Button("Save trigger preferences", action: viewModel.save)
            .font(MindMoryTypography.labelLarge)
            .foregroundStyle(MindMoryColors.Surface.primary)
    }
}
