import SwiftUI

struct SettingsNotificationCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Notification access")
                            .font(MindMoryTypography.titleMedium)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text("Allow reminders to arrive on your device.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }

                    Spacer()

                    SettingsStatusBadge(
                        title: label(for: viewModel.status(for: .notifications)),
                        tint: tint(for: viewModel.status(for: .notifications))
                    )
                }

                if viewModel.status(for: .notifications) != .granted {
                    Button(action: {
                        Task { await viewModel.requestAccess(for: .notifications) }
                    }) {
                        HStack(spacing: MindMorySpacing.xs) {
                            Text(viewModel.actionTitle(for: .notifications))
                                .font(MindMoryTypography.bodyMedium)
                        }
                        .foregroundStyle(MindMoryColors.Surface.background)
                        .padding(.horizontal, MindMorySpacing.md)
                        .padding(.vertical, MindMorySpacing.sm)
                        .background(MindMoryColors.Surface.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.requestingArea == .notifications)
                }
            }
        }
    }

    private func label(for status: PermissionStatus) -> String {
        switch status {
        case .notDetermined: return "Pending"
        case .granted: return "Enabled"
        case .denied: return "Needs review"
        }
    }

    private func tint(for status: PermissionStatus) -> Color {
        switch status {
        case .notDetermined: return MindMoryColors.Content.secondary
        case .granted: return MindMoryColors.Feedback.success
        case .denied: return MindMoryColors.Feedback.error
        }
    }
}

#if DEBUG
struct SettingsNotificationCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsNotificationCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
