import SwiftUI

struct SettingsQACardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                sectionTitle(
                    title: "QA Debug",
                    subtitle: "Debug/testing only. Hidden from Release builds."
                )

                Toggle(
                    "Enable QA Debug Mode",
                    isOn: Binding(
                        get: { viewModel.qaDebugModeEnabled },
                        set: { viewModel.qaDebugModeEnabled = $0 }
                    )
                )
                .font(MindMoryTypography.bodyLarge)
                .tint(MindMoryColors.Surface.primary)

                if viewModel.qaDebugModeEnabled {
                    Divider().overlay(MindMoryColors.Border.subtle)

                    SettingsNavigationRow(
                        title: "Open QA Debug Tools",
                        subtitle: "Reset onboarding and test Home card photos.",
                        summary: "Debug mode enabled",
                        iconName: "wrench.and.screwdriver.fill",
                        destination: { QADebugToolsView(viewModel: viewModel.makeQADebugToolsViewModel()) }
                    )
                }
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
struct SettingsQACardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsQACardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
