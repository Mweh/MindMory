import SwiftUI

struct SettingsView: View {

    @StateObject var viewModel: SettingsViewModel
    @StateObject var triggersViewModel: ContextualTriggersViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    headerSection
                    permissionSection
                    ContextualTriggersView(viewModel: triggersViewModel)
                    WidgetPreviewCardView()
                    privacySection
                }
                .padding(MindMorySpacing.xl)
            }
            .background(MindMoryColors.background.ignoresSafeArea())
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Settings")
                .font(MindMoryTypography.displayLarge)

            Text("Shape how MindMory understands context, words reminders gently, and protects your privacy.")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }

    private var permissionSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                Text("Permission Education")
                    .font(MindMoryTypography.headingMedium)

                ForEach(viewModel.permissionRows) { row in
                    PermissionRowView(
                        row: row,
                        statusLabel: label(for: row.status)
                    )
                }

                PrimaryButton(
                    title: "Enable Smart Reminders",
                    action: {
                        Task {
                            await viewModel.requestAll()
                        }
                    }
                )
                .disabled(viewModel.isRequestingPermissions)
            }
        }
    }

    private var privacySection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Privacy")
                    .font(MindMoryTypography.headingMedium)

                Text(
                    "Context helps MindMory decide when a reminder feels useful. "
                        + "This foundation uses mock data while the team defines production privacy rules."
                )
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }
        }
    }

    private func label(for status: PermissionStatus) -> String {
        switch status {
        case .notDetermined:
            return "Not set"

        case .granted:
            return "Enabled"

        case .denied:
            return "Needs review"
        }
    }
}

private struct PermissionRowView: View {

    let row: PermissionRowModel
    let statusLabel: String

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                Text(row.title)
                    .font(MindMoryTypography.bodyMedium)

                Text(row.description)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }

            Spacer()

            Text(statusLabel)
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.primaryGreen)
        }
    }
}

#Preview {
    SettingsView(
        viewModel: DependencyContainer().makeSettingsViewModel(),
        triggersViewModel: DependencyContainer().makeContextualTriggersViewModel()
    )
}
