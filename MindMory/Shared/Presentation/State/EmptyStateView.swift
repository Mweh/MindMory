import SwiftUI

struct EmptyStateView: View {

    let title: String
    let message: String

    var body: some View {
        VStack(spacing: MindMorySpacing.sm) {
            IconBadgeView(systemName: "sparkles")

            Text(title)
                .font(MindMoryTypography.display)
                .foregroundStyle(MindMoryColors.Content.primary)

            Text(message)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(MindMorySpacing.xl)
    }
}
