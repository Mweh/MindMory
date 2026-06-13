import SwiftUI

struct SettingsDeliveryCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
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
                    destination: { CustomizePreferencesDetailView(viewModel: viewModel) }
                )
            }
        }
    }

    private func sectionTitle(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
            Text(title)
                .font(MindMoryTypography.titleMedium)

            Text(subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }
}

#if DEBUG
struct SettingsDeliveryCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDeliveryCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
