import SwiftUI

struct PhotoAccessDeniedCardView: View {
    let allowAction: () -> Void

    var body: some View {
        HomeStateCardContainer {
            VStack(spacing: MindMorySpacing.xl) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 58, weight: .regular))
                    .foregroundStyle(MindMoryColors.deepGreen)

                PrimaryButton(
                    title: "Allow Photo Access",
                    action: allowAction
                )

                Text("You might want to see your\nprevious memory")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundStyle(MindMoryColors.deepGreen)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, MindMorySpacing.lg)
        }
    }
}
