import SwiftUI

struct PhotoAccessDeniedCardView: View {
    let allowAction: () -> Void

    var body: some View {
        HomeStateCardContainer {
            VStack(spacing: MindMorySpacing.xl) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(MindMoryTypography.display)
                    .foregroundStyle(MindMoryColors.Surface.primary)

                PrimaryButton(
                    title: "Allow Photo Access",
                    action: allowAction
                )

                Text("You might want to see your\nprevious memory")
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Surface.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, MindMorySpacing.lg)
        }
    }
}

#if DEBUG
struct PhotoAccessDeniedCardView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoAccessDeniedCardView(allowAction: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    PhotoAccessDeniedCardView(allowAction: {})
        .padding()
        .background(MindMoryColors.Surface.background)
}
