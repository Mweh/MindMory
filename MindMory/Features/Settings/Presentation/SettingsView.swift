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
        PageLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.xl,
                leading: MindMorySpacing.lg,
                bottom: MindMorySpacing.xl,
                trailing: MindMorySpacing.lg
            ),
            background: { backgroundView.ignoresSafeArea() }
        ) {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.refreshStatuses()
        }
    }

    private var backgroundView: some View {
        MindMoryColors.Surface.background
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            MindMoryColors.Surface.elevated,
                            MindMoryColors.Surface.surface,
                            MindMoryColors.Surface.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(spacing: MindMorySpacing.xs) {
                    SettingsHeroBadge(title: "Adaptive")
                    SettingsHeroBadge(title: "Context-aware")
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Settings")
                        .font(MindMoryTypography.headline)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text("A few small adjustments can help MindMory deliver better reminders and make it easier to preserve the moments you'd otherwise forget.")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }
            }
            .padding(MindMorySpacing.xl)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 220)
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }

    private var reminderSettingSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Reminder setting",
                description: "Choose whether to use the app default reminder mode or customize your own preference settings.",
                size: .medium
            )
            SettingsReminderSettingCardView(viewModel: viewModel)
        }
    }

    private var notificationSection: some View {
        SettingsNotificationCardView(viewModel: viewModel)
    }

    private var locationContextSection: some View {
        SettingsToggleTileCardView(
            title: "Location reminder",
            description: "Let your location guide your reminders.",
            isOn: $viewModel.preferences.location.usesLocationContext,
            navigationTitle: "Select point of interest",
            navigationSubtitle: "Help MindMory understand which places matter most to you.",
            navigationSummary: viewModel.preferences.locationSummary,
            iconName: "map.fill",
            destination: { LocationSettingsDetailView(viewModel: viewModel) },
            disabledTitle: "Location reminders are off",
            disabledDescription: "The app will not deliver any location-based reminders until this is turned on."
        )
    }

    private var calendarContextSection: some View {
        SettingsToggleTileCardView(
            title: "Schedule reminder",
            description: "Receive photo reminders around the events that matter to you.",
            isOn: $viewModel.preferences.schedule.usesCalendarContext,
            navigationTitle: "Select event reminders",
            navigationSubtitle: "Help MindMory focus on the events that matter most to you.",
            navigationSummary: viewModel.preferences.scheduleSummary,
            iconName: "calendar.badge.clock",
            destination: { ScheduleSettingsDetailView(viewModel: viewModel) },
            disabledTitle: "Calendar reminders are off",
            disabledDescription: "The app will not deliver any calendar-based reminders until this is turned on."
        )
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Delivery & personalization",
                description: "Adjust when and how reminders arrive.",
                size: .medium
            )

            SettingsDeliveryCardView(viewModel: viewModel)
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Privacy & behavior notes",
                description: "These settings show real permissions and reminder preferences.",
                size: .medium
            )

            SettingsPrivacyCardView()
        }
    }

    #if DEBUG
    private var qaDebugSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "QA Debug",
                description: "Debug/testing only. Hidden from Release builds.",
                size: .medium
            )

            SettingsToggleTileCardView(
                title: "Enable QA Debug Mode",
                description: "Turn on debug tools for QA and testing workflows.",
                isOn: Binding(
                    get: { viewModel.qaDebugModeEnabled },
                    set: { viewModel.qaDebugModeEnabled = $0 }
                ),
                navigationTitle: "Open QA Debug Tools",
                navigationSubtitle: "Reset onboarding and test Home card photos.",
                navigationSummary: "Debug mode enabled",
                iconName: "wrench.and.screwdriver.fill",
                destination: { QADebugToolsView(viewModel: viewModel.makeQADebugToolsViewModel()) },
                disabledTitle: nil,
                disabledDescription: nil
            )
        }
    }
    #endif

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
            return MindMoryColors.Content.secondary
        case .granted:
            return MindMoryColors.Feedback.success
        case .denied:
            return MindMoryColors.Feedback.error
        }
    }
}

struct SettingsHeroBadge: View {
    let title: String

    var body: some View {
        Badge(iconName: nil, text: title, tint: MindMoryColors.Surface.primary, style: .textOnly, cornerRadius: MindMoryRadius.medium)
    }
}


struct SettingsStatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Badge(iconName: nil, text: title, tint: tint, style: .textOnly)
    }
}

struct SettingsNavigationRow<Destination: View>: View {
    let title: String
    let subtitle: String
    let summary: String
    let iconName: String
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .fill(MindMoryColors.Surface.elevated)
                        .frame(width: 36, height: 36)

                    Image(systemName: iconName)
                        .font(MindMoryTypography.bodyLarge)
                        .foregroundStyle(MindMoryColors.Surface.primary)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                    Text(title)
                        .font(MindMoryTypography.bodyLarge)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    Text(summary)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Surface.primary)
                        .padding(.top, MindMorySpacing.xxs)
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: "chevron.right")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .padding(.top, MindMorySpacing.xs)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsRadioNavigationRow<Destination: View>: View {
    let title: String
    let subtitle: String
    let linkTitle: String
    let isSelected: Bool
    let destination: () -> Destination
    let selectAction: () -> Void

    var body: some View {
        RadioSelectionRow(
            title: title,
            subtitle: subtitle,
            isSelected: isSelected,
            action: selectAction
        ) {
            NavigationLink(destination: destination()) {
                Text(linkTitle)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Surface.primary)
            }
            .buttonStyle(.plain)
            .padding(.top, MindMorySpacing.xxs)
        }
    }
}

struct SettingsBulletRow: View {
    let iconName: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: MindMorySpacing.sm) {
            Image(systemName: iconName)
                .font(MindMoryTypography.bodyLarge)
                .foregroundStyle(MindMoryColors.Surface.primary)
                .frame(minWidth: 28, minHeight: 28)

            SectionTitle(
                title: title,
                description: description,
                size: .small
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                    Text(title)
                        .font(MindMoryTypography.bodyLarge)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    secondaryContent
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(MindMoryTypography.bodyLarge)
                    .frame(width: 26, height: 26)
                    .foregroundStyle(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Border.subtle)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(viewModel: DependencyContainer().makeSettingsViewModel())
}
