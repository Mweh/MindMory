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
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large)
            )
            .padding(
                .horizontal,
                index == 2 ? 0 : MindMorySpacing.xl
            )
            .accessibilityHidden(true)
    }

    private var titleText: some View {
        Text(page.title)
            .font(MindMoryTypography.headingLarge)
            .foregroundStyle(MindMoryColors.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, MindMorySpacing.xxl)
    }
}

#Preview {
    OnboardingPageView(
        page: PreviewData.onboardingPages[2],
        index: 2
    )
    .background(MindMoryColors.background)
}
