import SwiftUI

struct SettingsMessagePreviewCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Preview")
                    .font(MindMoryTypography.titleMedium)

                Text(viewModel.sampleNotificationTitle)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

                Text(viewModel.sampleNotificationBody)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
            }
        }
    }
}

#if DEBUG
struct SettingsMessagePreviewCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMessagePreviewCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
