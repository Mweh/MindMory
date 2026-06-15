import SwiftUI

struct SettingsDeliveryCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
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

#if DEBUG
struct SettingsDeliveryCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsDeliveryCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
