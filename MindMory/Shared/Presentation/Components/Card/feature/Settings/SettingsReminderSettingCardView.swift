import SwiftUI

struct SettingsReminderSettingCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                RadioSelectionRow(
                    title: ReminderSettingMode.appDefault.title,
                    subtitle: ReminderSettingMode.appDefault.subtitle,
                    isSelected: viewModel.preferences.reminderSettingMode == .appDefault,
                    action: { viewModel.preferences.reminderSettingMode = .appDefault }
                )

                Divider().overlay(MindMoryColors.Border.subtle)

                SettingsRadioNavigationRow(
                    title: ReminderSettingMode.customize.title,
                    subtitle: ReminderSettingMode.customize.subtitle,
                    linkTitle: "Open customize preference settings",
                    isSelected: viewModel.preferences.reminderSettingMode == .customize,
                    destination: { CustomizePreferencesDetailView(viewModel: viewModel) },
                    selectAction: { viewModel.preferences.reminderSettingMode = .customize }
                )
            }
        }
    }
}

#if DEBUG
struct SettingsReminderSettingCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsReminderSettingCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
