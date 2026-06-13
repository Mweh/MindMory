import SwiftUI

struct SettingsCustomizeLocationControlCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                ForEach(LocationNotificationTiming.allCases) { option in
                    RadioSelectionRow(
                        title: option.title,
                        subtitle: option.subtitle,
                        isSelected: selectedNotificationTiming == option,
                        action: { setNotificationTiming(option) }
                    )

                    if option.id != LocationNotificationTiming.allCases.last?.id {
                        Divider().overlay(MindMoryColors.Border.subtle)
                    }
                }

                Divider().overlay(MindMoryColors.Border.subtle)

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
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
            }
        }
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

#if DEBUG
struct SettingsCustomizeLocationControlCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCustomizeLocationControlCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
