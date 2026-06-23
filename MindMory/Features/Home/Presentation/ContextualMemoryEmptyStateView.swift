import SwiftUI

struct ContextualMemoryEmptyStateView: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            HStack(spacing: MindMorySpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .fill(MindMoryColors.Surface.primary.opacity(0.14))
                        .frame(width: 64, height: 64)

                    Image(systemName: systemImage)
                        .font(.system(size: 26, weight: .semibold, design: .rounded))
                        .foregroundStyle(MindMoryColors.Surface.primary)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text(title)
                        .font(MindMoryTypography.titleLarge)
                        .foregroundStyle(MindMoryColors.Content.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(MindMorySpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }
}
