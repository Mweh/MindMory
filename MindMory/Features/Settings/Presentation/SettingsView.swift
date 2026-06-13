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
        .task {
            await viewModel.refreshStatuses()
        }
    }

    private var backgroundView: some View {
        ZStack {
            MindMoryColors.Surface.background

            Circle()
                .fill(MindMoryColors.Surface.elevated.opacity(0.9))
                .frame(width: 240, height: 240)
                .blur(radius: 6)
                .offset(x: 170, y: -260)

            Circle()
                .fill(MindMoryColors.Surface.surface.opacity(0.95))
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
                            MindMoryColors.Surface.elevated,
                            MindMoryColors.Surface.surface,
                            MindMoryColors.Surface.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(MindMoryColors.Surface.primary.opacity(0.12))
                .frame(width: 180, height: 180)
                .offset(x: 120, y: -56)

            Circle()
                .fill(MindMoryColors.Content.secondary.opacity(0.10))
                .frame(width: 120, height: 120)
                .offset(x: 238, y: 18)

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
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
                .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }

    private var reminderSettingSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text("Reminder setting")
                    .font(MindMoryTypography.titleMedium)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text("Choose whether to use the app default reminder mode or customize your own preference settings.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }
            SettingsReminderSettingCardView(viewModel: viewModel)
        }
    }

    private var notificationSection: some View {
        SettingsNotificationCardView(viewModel: viewModel)
    }

    private var locationContextSection: some View {
        SettingsLocationCardView(viewModel: viewModel)
    }

    private var calendarContextSection: some View {
        SettingsCalendarCardView(viewModel: viewModel)
    }

    private var deliverySection: some View {
        SettingsDeliveryCardView(viewModel: viewModel)
    }

    private var privacySection: some View {
        SettingsPrivacyCardView()
    }

    #if DEBUG
    private var qaDebugSection: some View {
        SettingsQACardView(viewModel: viewModel)
    }
    #endif

    private func sectionTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
            Text(title)
                .font(MindMoryTypography.titleMedium)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
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
        Text(title)
            .font(MindMoryTypography.bodySmall)
            .foregroundStyle(MindMoryColors.Surface.primary)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
                .background(MindMoryColors.Surface.background.opacity(0.94))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
    }
}


struct SettingsStatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(MindMoryTypography.bodySmall)
            .foregroundStyle(tint)
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(tint.opacity(0.10))
            .clipShape(Capsule())
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
                        .frame(width: 46, height: 46)

                    Image(systemName: iconName)
                        .font(MindMoryTypography.labelSmall)
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
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: MindMorySpacing.sm) {
            Image(systemName: iconName)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(MindMoryColors.Surface.primary)
                .frame(width: 20)

            Text(text)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
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
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    secondaryContent
                }

                Spacer(minLength: MindMorySpacing.md)

                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Border.subtle)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(viewModel: DependencyContainer().makeSettingsViewModel())
}
