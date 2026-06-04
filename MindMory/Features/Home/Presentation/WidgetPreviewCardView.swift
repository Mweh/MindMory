import SwiftUI

struct WidgetPreviewCardView: View {
    var body: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("MindMory")
                        .font(MindMoryTypography.bodyMedium)
                        .bold()
                    Text("3 Moments this week")
                        .font(MindMoryTypography.headingMedium)
                    Text("Aroma Coffee")
                        .font(MindMoryTypography.caption)
                        .foregroundStyle(MindMoryColors.textSecondary)
                    Text("Great conversations are worth remembering.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
                Spacer()
                IconBadgeView(systemName: "sparkles")
            }
        }
        .background(MindMoryColors.surface)
    }
}
