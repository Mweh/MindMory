import SwiftUI

struct SettingsReminderCadenceCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                Text("Reminder cadence")
                    .font(MindMoryTypography.titleMedium)
                    .foregroundStyle(MindMoryColors.Content.primary)

                ForEach(NotificationDeliveryMode.allCases) { option in
                    RadioSelectionRow(
                        title: option.title,
                        subtitle: option.description,
                        isSelected: viewModel.preferences.delivery.mode == option,
                        action: { viewModel.preferences.delivery.mode = option }
                    )

                    if option.id != NotificationDeliveryMode.allCases.last?.id {
                        Divider().overlay(MindMoryColors.Border.subtle)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsReminderCadenceCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsReminderCadenceCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
