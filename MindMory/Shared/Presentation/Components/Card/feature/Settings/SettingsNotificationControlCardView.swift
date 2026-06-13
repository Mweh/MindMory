import SwiftUI

struct SettingsNotificationControlCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
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
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
            }
        }
    }
}

#if DEBUG
struct SettingsNotificationControlCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationControlCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
