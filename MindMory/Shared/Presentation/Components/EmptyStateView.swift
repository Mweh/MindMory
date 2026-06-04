import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: MindMorySpacing.sm) {
            IconBadgeView(systemName: "sparkles")
            Text(title).font(MindMoryTypography.headingMedium).foregroundStyle(MindMoryColors.textPrimary)
            Text(message).font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.textSecondary).multilineTextAlignment(.center)
        }
        .padding(MindMorySpacing.xl)
    }
}
