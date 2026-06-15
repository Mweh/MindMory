import SwiftUI

struct SettingsToggleTileCardView<Destination: View>: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let navigationTitle: String
    let navigationSubtitle: String
    let navigationSummary: String
    let iconName: String
    let destination: () -> Destination
    let disabledTitle: String?
    let disabledDescription: String?

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text(title)
                            .font(MindMoryTypography.titleMedium)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text(description)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }

                    Spacer()

                    Toggle(isOn: $isOn) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
                }

                if isOn || disabledTitle != nil {
                    Divider().overlay(MindMoryColors.Border.subtle)
                }

                if isOn {
                    SettingsNavigationRow(
                        title: navigationTitle,
                        subtitle: navigationSubtitle,
                        summary: navigationSummary,
                        iconName: iconName,
                        destination: destination
                    )
                } else if let disabledTitle, let disabledDescription {
                    HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .fill(MindMoryColors.Surface.elevated)
                                .frame(width: 36, height: 36)

                            Image(systemName: "bell.slash.fill")
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.Content.secondary)
                        }

                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text(disabledTitle)
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.Content.primary)

                            Text(disabledDescription)
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.Content.secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsToggleTileCardView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isOn = false

        var body: some View {
            SettingsToggleTileCardView(
                title: "Location reminder",
                description: "Let your location guide your reminders.",
                isOn: $isOn,
                navigationTitle: "Select point of interest",
                navigationSubtitle: "Help MindMory understand which places matter most to you.",
                navigationSummary: "Home, Work, Favorites",
                iconName: "map.fill",
                destination: { EmptyView() },
                disabledTitle: "Location reminders are off",
                disabledDescription: "The app will not deliver any location-based reminders until this is turned on."
            )
            .padding()
            .previewLayout(.sizeThatFits)
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
