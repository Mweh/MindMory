import SwiftUI

struct WidgetPreviewCardView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text("MindMory")
                    .font(MindMoryTypography.bodyMedium)
                    .bold()
                Text("3 Moments this week")
                    .font(MindMoryTypography.titleMedium)
                Text("Aroma Coffee")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                Text("Great conversations are worth remembering.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }
            Spacer()
            Badge(iconName: "sparkles", text: nil, tint: MindMoryColors.Content.primary, style: .iconOnly)
        }
        .padding(MindMorySpacing.lg)
        .mindMoryCardStyle()
        .background(MindMoryColors.Surface.surface)
    }
}

#if DEBUG
struct WidgetPreviewCardView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPreviewCardView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    WidgetPreviewCardView()
        .padding()
        .background(MindMoryColors.Surface.background)
}
