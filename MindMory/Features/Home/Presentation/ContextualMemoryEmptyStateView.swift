import SwiftUI

struct ContextualMemoryEmptyStateView: View {
    let title: String
    let subtitle: String
    var systemImage: String = "sparkles"

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(MindMoryColors.primaryGreen)

            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text(subtitle)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(MindMoryColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindMorySpacing.lg)
        .background(MindMoryColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        }
    }
}
