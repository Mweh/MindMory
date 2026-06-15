import SwiftUI

struct EmptyStateView: View {

    let title: String
    let message: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(spacing: MindMorySpacing.lg) {
            ZStack {
                Circle()
                    .fill(MindMoryColors.Surface.primary.opacity(0.12))
                    .frame(width: 86, height: 86)

                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(MindMoryColors.Surface.primary)
            }

            VStack(spacing: MindMorySpacing.sm) {
                Text(title)
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: 360)
        }
        .padding(MindMorySpacing.xl)
        .frame(maxWidth: .infinity)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .shadow(color: MindMoryColors.Surface.primary.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}
