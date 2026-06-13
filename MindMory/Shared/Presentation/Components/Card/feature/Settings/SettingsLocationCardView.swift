import SwiftUI

struct SettingsLocationCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Location reminder")
                            .font(MindMoryTypography.titleMedium)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text("Let your location guide your reminders.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }

                    Spacer()

                    Toggle(isOn: $viewModel.preferences.location.usesLocationContext) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
                }

                Divider().overlay(MindMoryColors.Border.subtle)

                if viewModel.preferences.location.usesLocationContext {
                    SettingsNavigationRow(
                        title: "Select point of interest",
                        subtitle: "Help MindMory understand which places matter most to you.",
                        summary: viewModel.preferences.locationSummary,
                        iconName: "map.fill",
                        destination: { LocationSettingsDetailView(viewModel: viewModel) }
                    )
                } else {
                    HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .fill(MindMoryColors.Surface.elevated)
                                .frame(width: 42, height: 42)

                            Image(systemName: "bell.slash.fill")
                                .font(MindMoryTypography.labelSmall)
                                .foregroundStyle(MindMoryColors.Content.secondary)
                        }

                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text("Location reminders are off")
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.Content.primary)

                            Text("The app will not deliver any location-based reminders until this is turned on.")
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
struct SettingsLocationCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLocationCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
