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
        Image(page.imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium)
            )
            .padding(
                .horizontal,
                page.imageName == "onboard3" ? 0 : MindMorySpacing.xl
            )
            .accessibilityHidden(true)
    }

    private var titleText: some View {
        Text(page.title)
            .font(MindMoryTypography.headline)
            .foregroundStyle(MindMoryColors.Content.primary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
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
