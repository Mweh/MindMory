import SwiftUI

private func settingsDetailPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    ScrollView(showsIndicators: false) {
        content()
            .padding(.horizontal, MindMorySpacing.lg)
    }
    .background(MindMoryColors.Surface.background.ignoresSafeArea())
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
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text("When enabled, location reminders will use the POI categories you select.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                SettingsPOIFilterCardView(viewModel: viewModel)
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
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text("Choose the calendar event types and rules that should trigger reminders.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                SettingsScheduleFilterCardView(viewModel: viewModel)
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
                        .font(MindMoryTypography.titleMedium)

                    Text("Choose how location reminders trigger when you arrive or stay.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                SettingsCustomizeLocationControlCardView(viewModel: viewModel)

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Calendar reminder control")
                        .font(MindMoryTypography.titleMedium)

                    Text("Adjust when calendar reminders should appear and what events to include.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }
                .padding(.bottom, MindMorySpacing.xs)

                SettingsCustomizeCalendarControlCardView(viewModel: viewModel)

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Notification control")
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text("Choose how location reminders trigger when you arrive or stay.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                SettingsNotificationControlCardView(viewModel: viewModel)

                SettingsMessageToneCardView(viewModel: viewModel)

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

                SettingsReminderCadenceCardView(viewModel: viewModel)

                SettingsNotificationControlCardView(viewModel: viewModel)
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

                SettingsMessageToneCardView(viewModel: viewModel)

                SettingsMessageContextCardView(viewModel: viewModel)

                SettingsMessagePreviewCardView(viewModel: viewModel)
            }
        }
        .navigationTitle("Message style")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsDetailHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(title)
                .font(MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Content.primary)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }
}

struct SettingsSelectableTile: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: MindMorySpacing.xs) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.link)

                Text(title)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, minHeight: 90, alignment: .center)
            .padding(.vertical, MindMorySpacing.sm)
            .padding(.horizontal, MindMorySpacing.md)
            .background(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Surface.surface)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct SettingsSelectableRow: View {
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
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(isSelected ? MindMoryColors.Content.link : MindMoryColors.Border.subtle)
            }
        }
        .buttonStyle(.plain)
    }
}


struct SettingsMenuPicker<PickerContent: View>: View {
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
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text(selectionTitle)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }

            Spacer(minLength: MindMorySpacing.md)

            pickerContent()
                .pickerStyle(.menu)
                .labelsHidden()
        }
    }
}

struct SettingsSecondaryPillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(MindMoryTypography.labelSmall)
            .foregroundStyle(MindMoryColors.Content.link)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(MindMoryColors.Surface.surface)
            .clipShape(Capsule())
            .buttonStyle(.plain)
    }
}