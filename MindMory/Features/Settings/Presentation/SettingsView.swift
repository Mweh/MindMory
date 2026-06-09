import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private enum SettingsDestination: Hashable {
    case location
    case schedule
    case delivery
    case message
    case customize
    #if DEBUG
    case qaDebugTools
    #endif
}

struct SettingsView: View {

    @StateObject var viewModel: SettingsViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    heroSection
                    notificationSection
                    locationContextSection
                    calendarContextSection
                    reminderSettingSection
                    privacySection
                    #if DEBUG
                    qaDebugSection
                    #endif
                }
                .padding(.horizontal, MindMorySpacing.lg)
                .padding(.vertical, MindMorySpacing.xl)
            }
            .background(backgroundView.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .location:
                    LocationSettingsDetailView(viewModel: viewModel)
                case .schedule:
                    ScheduleSettingsDetailView(viewModel: viewModel)
                case .delivery:
                    NotificationDeliverySettingsView(viewModel: viewModel)
                case .message:
                    MessageSettingsDetailView(viewModel: viewModel)
                case .customize:
                    CustomizePreferencesDetailView(viewModel: viewModel)
                #if DEBUG
                case .qaDebugTools:
                    QADebugToolsView(viewModel: viewModel.makeQADebugToolsViewModel())
                #endif
                }
            }
            .task {
                await viewModel.refreshStatuses()
            }
        }
    }

    private var backgroundView: some View {
        ZStack {
            MindMoryColors.background

            Circle()
                .fill(MindMoryColors.surfaceStrong.opacity(0.9))
                .frame(width: 240, height: 240)
                .blur(radius: 6)
                .offset(x: 170, y: -260)

            Circle()
                .fill(MindMoryColors.surface.opacity(0.95))
                .frame(width: 220, height: 220)
                .offset(x: -150, y: 360)
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            MindMoryColors.surfaceStrong,
                            MindMoryColors.surface,
                            MindMoryColors.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(MindMoryColors.primaryGreen.opacity(0.12))
                .frame(width: 180, height: 180)
                .offset(x: 120, y: -56)

            Circle()
                .fill(MindMoryColors.mutedIndigo.opacity(0.10))
                .frame(width: 120, height: 120)
                .offset(x: 238, y: 18)

            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(spacing: MindMorySpacing.xs) {
                    SettingsHeroBadge(title: "Adaptive")
                    SettingsHeroBadge(title: "Context-aware")
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Settings")
                        .font(MindMoryTypography.displayLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text("A few small adjustments can help MindMory deliver better reminders and make it easier to preserve the moments you'd otherwise forget.")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
            }
            .padding(MindMorySpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
                .stroke(MindMoryColors.border, lineWidth: 1)
        )
        .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }

    private var reminderSettingSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text("Reminder setting")
                    .font(MindMoryTypography.headingMedium)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text("Choose whether to use the app default reminder mode or customize your own preference settings.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }

            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                    RadioSelectionRow(
                        title: ReminderSettingMode.appDefault.title,
                        subtitle: ReminderSettingMode.appDefault.subtitle,
                        isSelected: viewModel.preferences.reminderSettingMode == .appDefault,
                        action: {
                            viewModel.preferences.reminderSettingMode = .appDefault
                        }
                    )

                    Divider()
                        .overlay(MindMoryColors.border)

                    SettingsRadioNavigationRow(
                        title: ReminderSettingMode.customize.title,
                        subtitle: ReminderSettingMode.customize.subtitle,
                        linkTitle: "Open customize preference settings",
                        isSelected: viewModel.preferences.reminderSettingMode == .customize,
                        destination: .customize,
                        selectAction: {
                            viewModel.preferences.reminderSettingMode = .customize
                        }
                    )
                }
            }
        }
    }

    private var notificationSection: some View {
        let status = viewModel.status(for: .notifications)

        return AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Notification access")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        Text("Allow reminders to arrive on your device.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }

                    Spacer()

                    SettingsStatusBadge(
                        title: label(for: status),
                        tint: tint(for: status)
                    )
                }

                if status != .granted {
                    Button(action: {
                        handlePermissionAction(for: .notifications)
                    }) {
                        HStack(spacing: MindMorySpacing.xs) {
                            if viewModel.requestingArea == .notifications {
                                ProgressView()
                                    .tint(MindMoryColors.background)
                            }

                            Text(viewModel.actionTitle(for: .notifications))
                                .font(MindMoryTypography.bodyMedium)
                        }
                        .foregroundStyle(MindMoryColors.background)
                        .padding(.horizontal, MindMorySpacing.md)
                        .padding(.vertical, MindMorySpacing.sm)
                        .background(MindMoryColors.primaryGreen)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.requestingArea == .notifications)
                }
            }
        }
    }

    private var locationContextSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Location reminder")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        Text("Let your location guide your reminders.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }

                    Spacer()

                    Toggle(isOn: $viewModel.preferences.location.usesLocationContext) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                }

                Divider()
                    .overlay(MindMoryColors.border)

                if viewModel.preferences.location.usesLocationContext {
                    SettingsNavigationRow(
                        title: "Select point of interest",
                        subtitle: "Help MindMory understand which places matter most to you.",
                        summary: viewModel.preferences.locationSummary,
                        iconName: "map.fill",
                        destination: .location
                    )
                } else {
                    HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .fill(MindMoryColors.surfaceStrong)
                                .frame(width: 42, height: 42)

                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(MindMoryColors.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text("Location reminders are off")
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.textPrimary)

                            Text("The app will not deliver any location-based reminders until this is turned on.")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.textSecondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    private var calendarContextSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Schedule reminder")
                            .font(MindMoryTypography.headingMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        Text("Receive photo reminders around the events that matter to you.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }

                    Spacer()

                    Toggle(isOn: $viewModel.preferences.schedule.usesCalendarContext) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.primaryGreen))
                }

                Divider()
                    .overlay(MindMoryColors.border)

                if viewModel.preferences.schedule.usesCalendarContext {
                    SettingsNavigationRow(
                        title: "Select event reminders",
                        subtitle: "Help MindMory focus on the events that matter most to you.",
                        summary: viewModel.preferences.scheduleSummary,
                        iconName: "calendar.badge.clock",
                        destination: .schedule
                    )
                } else {
                    HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .fill(MindMoryColors.surfaceStrong)
                                .frame(width: 42, height: 42)

                            Image(systemName: "bell.slash.fill")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(MindMoryColors.textSecondary)
                        }

                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text("Calendar reminders are off")
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.textPrimary)

                            Text("The app will not deliver any calendar-based reminders until this is turned on.")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.textSecondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    private var deliverySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                sectionTitle(
                    title: "Delivery & personalization",
                    subtitle: "Adjust when and how reminders arrive."
                )

                SettingsNavigationRow(
                    title: "Customize preference setting",
                    subtitle: "Set delivery behavior and message style together.",
                    summary: viewModel.preferences.reminderSettingMode == .customize
                        ? "Custom mode • \(viewModel.preferences.deliverySummary)"
                        : "Default app mode • \(viewModel.preferences.deliverySummary)",
                    iconName: "slider.horizontal.3",
                    destination: .customize
                )
            }
        }
    }

    private var privacySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                sectionTitle(
                    title: "Privacy & behavior notes",
                    subtitle: "These settings show real permissions and reminder preferences."
                )

                SettingsBulletRow(
                    iconName: "checkmark.shield.fill",
                    text: "If a permission is denied, that trigger source is paused until the user re-enables it."
                )
                SettingsBulletRow(
                    iconName: "mappin.and.ellipse",
                    text: "Location preferences only affect POI categories, not sample places."
                )
                SettingsBulletRow(
                    iconName: "calendar.badge.exclamationmark",
                    text: "Calendar preferences use real events, not dummy schedules."
                )
            }
        }
    }

    #if DEBUG
    private var qaDebugSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                sectionTitle(
                    title: "QA Debug",
                    subtitle: "Debug/testing only. Hidden from Release builds."
                )

                Toggle(
                    "Enable QA Debug Mode",
                    isOn: Binding(
                        get: { viewModel.qaDebugModeEnabled },
                        set: { viewModel.qaDebugModeEnabled = $0 }
                    )
                )
                .font(MindMoryTypography.bodyLarge)
                .tint(MindMoryColors.primaryGreen)

                if viewModel.qaDebugModeEnabled {
                    Divider()
                        .overlay(MindMoryColors.border)

                    SettingsNavigationRow(
                        title: "Open QA Debug Tools",
                        subtitle: "Reset onboarding and test Home card photos.",
                        summary: "Debug mode enabled",
                        iconName: "wrench.and.screwdriver.fill",
                        destination: .qaDebugTools
                    )
                }
            }
        }
    }
    #endif

    private func sectionTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
            Text(title)
                .font(MindMoryTypography.headingMedium)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }

    private func handlePermissionAction(for area: SettingsAccessArea) {
        switch viewModel.status(for: area) {
        case .granted:
            return
        case .notDetermined:
            Task {
                await viewModel.requestAccess(for: area)
            }
        case .denied:
            openAppSettings()
        }
    }

    private func openAppSettings() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(url)
        #endif
    }

    private func label(for status: PermissionStatus) -> String {
        switch status {
        case .notDetermined:
            return "Pending"
        case .granted:
            return "Enabled"
        case .denied:
            return "Needs review"
        }
    }

    private func tint(for status: PermissionStatus) -> Color {
        switch status {
        case .notDetermined:
            return MindMoryColors.mutedIndigo
        case .granted:
            return MindMoryColors.success
        case .denied:
            return MindMoryColors.error
        }
    }
}

private struct SettingsHeroBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.primaryGreen)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(MindMoryColors.background.opacity(0.94))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(MindMoryColors.border, lineWidth: 1)
            )
    }
}


private struct SettingsStatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(MindMoryTypography.caption)
            .foregroundStyle(tint)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(tint.opacity(0.10))
            .clipShape(Capsule())
    }
}

private struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String
    let summary: String
    let iconName: String
    let destination: SettingsDestination

    var body: some View {
        NavigationLink(value: destination) {
            HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .fill(MindMoryColors.surfaceStrong)
                        .frame(width: 46, height: 46)

                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(MindMoryColors.primaryGreen)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                    Text(title)
                        .font(MindMoryTypography.bodyLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    Text(summary)
                        .font(MindMoryTypography.caption)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                        .padding(.top, MindMorySpacing.xxs)
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(MindMoryColors.textSecondary)
                    .padding(.top, MindMorySpacing.xs)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsRadioNavigationRow: View {
    let title: String
    let subtitle: String
    let linkTitle: String
    let isSelected: Bool
    let destination: SettingsDestination
    let selectAction: () -> Void

    var body: some View {
        RadioSelectionRow(
            title: title,
            subtitle: subtitle,
            isSelected: isSelected,
            action: selectAction
        ) {
            NavigationLink(value: destination) {
                Text(linkTitle)
                    .font(MindMoryTypography.caption)
                    .foregroundStyle(MindMoryColors.primaryGreen)
            }
            .buttonStyle(.plain)
            .padding(.top, MindMorySpacing.xxs)
        }
    }
}

private struct SettingsBulletRow: View {
    let iconName: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: MindMorySpacing.sm) {
            Image(systemName: iconName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(MindMoryColors.primaryGreen)
                .frame(width: 20)

            Text(text)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct RadioSelectionRow<SecondaryContent: View>: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    let secondaryContent: SecondaryContent

    init(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder secondaryContent: () -> SecondaryContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.action = action
        self.secondaryContent = secondaryContent()
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                    Text(title)
                        .font(MindMoryTypography.bodyLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    secondaryContent
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isSelected ? MindMoryColors.primaryGreen : MindMoryColors.border)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(viewModel: DependencyContainer().makeSettingsViewModel())
}
