import SwiftUI

private func settingsDetailPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ScrollView(showsIndicators: false) {
        content()
            .padding(.horizontal, MindMorySpacing.lg)
    }
    .background(MindMoryColors.background.ignoresSafeArea())
}

struct LocationSettingsDetailView: View {
    @ObservedObject var viewModel: SettingsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: MindMorySpacing.sm),
        GridItem(.flexible(), spacing: MindMorySpacing.sm),
        GridItem(.flexible(), spacing: MindMorySpacing.sm)
    ]

    private var selectedCategoryCountText: String {
        let count = viewModel.preferences.location.selectedCategories.count
        let label = count == 1 ? "point of interest selected" : "points of interest selected"
        return "\(count) \(label)"
    }

    var body: some View {
        settingsDetailPage {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Point of interest filter")
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text("When enabled, location reminders will use the POI categories you select.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        HStack {
                            Text(selectedCategoryCountText)
                                .font(MindMoryTypography.bodyMedium)
                                .foregroundStyle(MindMoryColors.textPrimary)

                            Spacer()

                            if !viewModel.preferences.location.selectedCategories.isEmpty {
                                SettingsSecondaryPillButton(
                                    title: "Clear",
                                    action: viewModel.clearLocationCategories
                                )
                            }
                        }

                        Divider()
                            .overlay(MindMoryColors.border)

                        LazyVGrid(columns: columns, spacing: MindMorySpacing.sm) {
                            ForEach(PointOfInterestCategory.allCases) { category in
                                SettingsSelectableTile(
                                    title: category.title,
                                    isSelected: viewModel.preferences.location.selectedCategories.contains(category),
                                    action: {
                                        viewModel.toggleLocationCategory(category)
                                    }
                                )
                            }
                        }

                        if viewModel.preferences.location.selectedCategories.isEmpty {
                            Text("Select at least one category to keep location-based reminders active.")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.error)
                        }

                        Divider()
                            .overlay(MindMoryColors.border)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

}

struct ScheduleSettingsDetailView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        settingsDetailPage {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Schedule filter")
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text("Choose the calendar event types and rules that should trigger reminders.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        HStack {
                            Text(selectedScheduleCountText)
                                .font(MindMoryTypography.bodyMedium)
                                .foregroundStyle(MindMoryColors.textPrimary)

                            Spacer()

                            if !viewModel.preferences.schedule.selectedCategories.isEmpty {
                                SettingsSecondaryPillButton(
                                    title: "Clear",
                                    action: viewModel.clearScheduleCategories
                                )
                            }
                        }

                        Divider()
                            .overlay(MindMoryColors.border)

                        ForEach(CalendarContextCategory.allCases) { category in
                            SettingsSelectableRow(
                                title: category.title,
                                subtitle: category.description,
                                isSelected: viewModel.preferences.schedule.selectedCategories.contains(category),
                                action: {
                                    viewModel.toggleScheduleCategory(category)
                                }
                            )

                            if category.id != CalendarContextCategory.allCases.last?.id {
                                Divider()
                                    .overlay(MindMoryColors.border)
                            }
                        }

                        if viewModel.preferences.schedule.selectedCategories.isEmpty {
                            Text("Select at least one calendar trigger if you want schedule reminders to stay active.")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.error)
                        }

                        Divider()
                            .overlay(MindMoryColors.border)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedScheduleCountText: String {
        let count = viewModel.preferences.schedule.selectedCategories.count
        let label = count == 1 ? "calendar event selected" : "calendar events selected"
        return "\(count) \(label)"
    }
}

struct CustomizePreferencesDetailView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        settingsDetailPage {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Location reminder control")
                        .font(MindMoryTypography.headingMedium)

                    Text("Choose how location reminders trigger when you arrive or stay.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        ForEach(LocationNotificationTiming.allCases) { option in
                            RadioSelectionRow(
                            title: option.title,
                            subtitle: option.subtitle,
                            isSelected: selectedNotificationTiming == option,
                            action: {
                                setNotificationTiming(option)
                            }
                        )

                            if option.id != LocationNotificationTiming.allCases.last?.id {
                                Divider()
                                    .overlay(MindMoryColors.border)
                            }
                        }

                        Divider()
                            .overlay(MindMoryColors.border)

                        SettingsMenuPicker(
                            title: "Repeat visits",
                            selectionTitle: viewModel.preferences.location.cooldown.title
                        ) {
                            Picker("Repeat visits", selection: $viewModel.preferences.location.cooldown) {
                                ForEach(LocationVisitCooldown.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        Toggle("Mention the place name", isOn: $viewModel.preferences.message.includesPlaceName)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                    }
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Calendar reminder control")
                        .font(MindMoryTypography.headingMedium)

                    Text("Adjust when calendar reminders should appear and what events to include.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
                .padding(.bottom, MindMorySpacing.xs)

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        SettingsMenuPicker(
                            title: "Reminder timing",
                            selectionTitle: viewModel.preferences.schedule.leadTime.title
                        ) {
                            Picker("Reminder timing", selection: $viewModel.preferences.schedule.leadTime) {
                                ForEach(ScheduleLeadTime.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        Toggle("Include all-day events", isOn: $viewModel.preferences.schedule.includesAllDayEvents)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))

                        Toggle("Include busy calendar blocks", isOn: $viewModel.preferences.schedule.includesBusyCalendarBlocks)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))

                        Toggle("Mention the event title", isOn: $viewModel.preferences.message.includesEventTitle)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                    }
                    .disabled(!viewModel.preferences.schedule.usesCalendarContext)
                    .opacity(viewModel.preferences.schedule.usesCalendarContext ? 1 : 0.6)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Notification control")
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text("Choose how location reminders trigger when you arrive or stay.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        SettingsMenuPicker(
                            title: "Repeat interval",
                            selectionTitle: viewModel.preferences.delivery.repeatInterval.title
                        ) {
                            Picker("Repeat interval", selection: $viewModel.preferences.delivery.repeatInterval) {
                                ForEach(ReminderRepeatInterval.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }
                        .opacity(viewModel.preferences.delivery.mode == .oneTime ? 0.45 : 1)
                        .disabled(viewModel.preferences.delivery.mode == .oneTime)

                        SettingsMenuPicker(
                            title: "Daily reminder cap",
                            selectionTitle: viewModel.preferences.delivery.dailyLimit.title
                        ) {
                            Picker("Daily reminder cap", selection: $viewModel.preferences.delivery.dailyLimit) {
                                ForEach(DailyReminderLimit.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        SettingsMenuPicker(
                            title: "Sound",
                            selectionTitle: viewModel.preferences.delivery.soundStyle.title
                        ) {
                            Picker("Sound", selection: $viewModel.preferences.delivery.soundStyle) {
                                ForEach(ReminderSoundStyle.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        Toggle("Respect Focus mode", isOn: $viewModel.preferences.delivery.respectsFocusMode)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        ForEach(ReminderMessageTone.allCases) { tone in
                            RadioSelectionRow(
                                title: tone.title,
                                subtitle: tone.example,
                                isSelected: viewModel.preferences.message.tone == tone,
                                action: {
                                    viewModel.preferences.message.tone = tone
                                }
                            )

                            if tone.id != ReminderMessageTone.allCases.last?.id {
                                Divider()
                                    .overlay(MindMoryColors.border)
                            }
                        }
                    }
                }

            }
        }
        .navigationTitle("Customize preferences")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectedNotificationTiming: LocationNotificationTiming {
        if viewModel.preferences.location.notifyAfterShortStay && !viewModel.preferences.location.notifyOnArrival {
            return .afterShortStay
        }
        return .arrival
    }

    private func setNotificationTiming(_ timing: LocationNotificationTiming) {
        viewModel.setLocationNotificationTiming(timing)
    }
}

struct NotificationDeliverySettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        settingsDetailPage {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                SettingsDetailHeader(
                    title: "Delivery behavior",
                    subtitle: "Decide how often reminders can appear, how long the app waits before repeating, and whether sounds or focus-mode rules should shape the experience."
                )

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        Text("Reminder cadence")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        ForEach(NotificationDeliveryMode.allCases) { option in
                            RadioSelectionRow(
                            title: option.title,
                            subtitle: option.description,
                            isSelected: viewModel.preferences.delivery.mode == option,
                            action: {
                                viewModel.preferences.delivery.mode = option
                            }
                        )

                            if option.id != NotificationDeliveryMode.allCases.last?.id {
                                Divider()
                                    .overlay(MindMoryColors.border)
                            }
                        }
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        Text("Limits & delivery details")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        SettingsMenuPicker(
                            title: "Repeat interval",
                            selectionTitle: viewModel.preferences.delivery.repeatInterval.title
                        ) {
                            Picker("Repeat interval", selection: $viewModel.preferences.delivery.repeatInterval) {
                                ForEach(ReminderRepeatInterval.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }
                        .opacity(viewModel.preferences.delivery.mode == .oneTime ? 0.45 : 1)
                        .disabled(viewModel.preferences.delivery.mode == .oneTime)

                        SettingsMenuPicker(
                            title: "Daily reminder cap",
                            selectionTitle: viewModel.preferences.delivery.dailyLimit.title
                        ) {
                            Picker("Daily reminder cap", selection: $viewModel.preferences.delivery.dailyLimit) {
                                ForEach(DailyReminderLimit.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        SettingsMenuPicker(
                            title: "Preferred window",
                            selectionTitle: viewModel.preferences.delivery.preferredWindow.title
                        ) {
                            Picker("Preferred window", selection: $viewModel.preferences.delivery.preferredWindow) {
                                ForEach(PreferredDeliveryWindow.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        SettingsMenuPicker(
                            title: "Sound",
                            selectionTitle: viewModel.preferences.delivery.soundStyle.title
                        ) {
                            Picker("Sound", selection: $viewModel.preferences.delivery.soundStyle) {
                                ForEach(ReminderSoundStyle.allCases) { option in
                                    Text(option.title).tag(option)
                                }
                            }
                        }

                        Toggle("Show message preview text", isOn: $viewModel.preferences.delivery.showsPreviewText)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))

                        Toggle("Respect Focus mode", isOn: $viewModel.preferences.delivery.respectsFocusMode)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                    }
                }
            }
        }
        .navigationTitle("Delivery behavior")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MessageSettingsDetailView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        settingsDetailPage {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                SettingsDetailHeader(
                    title: "Message style",
                    subtitle: "Personalize how a reminder sounds and how much context it shows, while still letting MindMory stay adaptive in the background."
                )

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        Text("Tone")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        ForEach(ReminderMessageTone.allCases) { tone in
                            RadioSelectionRow(
                                title: tone.title,
                                subtitle: tone.example,
                                isSelected: viewModel.preferences.message.tone == tone,
                                action: {
                                    viewModel.preferences.message.tone = tone
                                }
                            )

                            if tone.id != ReminderMessageTone.allCases.last?.id {
                                Divider()
                                    .overlay(MindMoryColors.border)
                            }
                        }
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                        Text("Included context")
                            .font(MindMoryTypography.headingMedium)

                        Toggle("Mention the place name when available", isOn: $viewModel.preferences.message.includesPlaceName)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))

                        Toggle("Mention the event title when available", isOn: $viewModel.preferences.message.includesEventTitle)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))

                        Toggle("Explain why the reminder appeared", isOn: $viewModel.preferences.message.explainsTriggerReason)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Preview")
                            .font(MindMoryTypography.headingMedium)

                        Text(viewModel.sampleNotificationTitle)
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        Text(viewModel.sampleNotificationBody)
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.textPrimary)
                    }
                }
            }
        }
        .navigationTitle("Message style")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettingsDetailHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(title)
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }
}

private struct SettingsSelectableTile: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: MindMorySpacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? MindMoryColors.background : MindMoryColors.primaryGreen)

                Text(title)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(isSelected ? MindMoryColors.background : MindMoryColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: 90, alignment: .center)
            .padding(.vertical, MindMorySpacing.sm)
            .padding(.horizontal, MindMorySpacing.md)
            .background(isSelected ? MindMoryColors.primaryGreen : MindMoryColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsSelectableRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                    Text(title)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? MindMoryColors.primaryGreen : MindMoryColors.border)
            }
        }
        .buttonStyle(.plain)
    }
}


private struct SettingsMenuPicker<PickerContent: View>: View {
    let title: String
    let selectionTitle: String
    @ViewBuilder let pickerContent: () -> PickerContent

    init(
        title: String,
        selectionTitle: String,
        @ViewBuilder pickerContent: @escaping () -> PickerContent
    ) {
        self.title = title
        self.selectionTitle = selectionTitle
        self.pickerContent = pickerContent
    }

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                Text(title)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text(selectionTitle)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }

            Spacer(minLength: MindMorySpacing.md)

            pickerContent()
                .pickerStyle(.menu)
                .labelsHidden()
        }
    }
}

private struct SettingsSecondaryPillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.primaryGreen)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(MindMoryColors.surface)
            .clipShape(Capsule())
            .buttonStyle(.plain)
    }
}