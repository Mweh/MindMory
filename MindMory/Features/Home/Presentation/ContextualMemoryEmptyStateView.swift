import SwiftUI

struct ContextualMemoryEmptyStateView: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Image(systemName: systemImage)
                .font(MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Surface.primary)

            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text(title)
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text(subtitle)
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindMorySpacing.lg)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        }
    }
}
