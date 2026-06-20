import SwiftUI

struct OnboardingPageView: View {

    let page: OnboardingPage
    let index: Int

    var body: some View {
        VStack(spacing: MindMorySpacing.xxxl) {
            illustrationImage
                .padding(.top, MindMorySpacing.xl)

            titleText

            Spacer(minLength: 0)
        }
    }

    private var illustrationImage: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .fill(MindMoryColors.Surface.background)

                Image(page.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            }
        }
        .frame(height: 360)
        .padding(.horizontal, MindMorySpacing.xl)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        .accessibilityHidden(true)
    }

    private var titleText: some View {
        Text(page.title)
            .font(MindMoryTypography.headline)
            .foregroundStyle(MindMoryColors.Content.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .lineLimit(3)
            .truncationMode(.tail)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, MindMorySpacing.xl)
    }
}

#Preview {
    OnboardingPageView(
        page: OnboardingPageCatalog.pages[2],
        index: 2
    )
    .background(MindMoryColors.Surface.background)
}
