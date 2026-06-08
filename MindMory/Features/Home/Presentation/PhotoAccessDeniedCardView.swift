import SwiftUI

struct PhotoAccessDeniedCardView: View {
    let allowAction: () -> Void

    var body: some View {
        HomeStateCardContainer {
            VStack(spacing: MindMorySpacing.xl) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 58, weight: .regular))
                    .foregroundStyle(MindMoryColors.deepGreen)

                Button(action: allowAction) {
                    Text("Allow Photo Access")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(MindMoryColors.deepGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(MindMoryColors.surface.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .stroke(MindMoryColors.deepGreen, lineWidth: 1)
                        }
                        .shadow(color: MindMoryColors.deepGreen.opacity(0.9), radius: 0, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, MindMorySpacing.md)

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

#Preview {
    PhotoAccessDeniedCardView(allowAction: {})
        .padding()
        .background(MindMoryColors.background)
}
