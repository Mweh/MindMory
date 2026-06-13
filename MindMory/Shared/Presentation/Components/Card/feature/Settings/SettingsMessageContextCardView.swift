import SwiftUI

struct SettingsMessageContextCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                Text("Included context")
                    .font(MindMoryTypography.titleMedium)

                Toggle("Mention the place name when available", isOn: $viewModel.preferences.message.includesPlaceName)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))

                Toggle("Mention the event title when available", isOn: $viewModel.preferences.message.includesEventTitle)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))

                Toggle("Explain why the reminder appeared", isOn: $viewModel.preferences.message.explainsTriggerReason)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
            }
        }
    }
}

#if DEBUG
struct SettingsMessageContextCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMessageContextCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
