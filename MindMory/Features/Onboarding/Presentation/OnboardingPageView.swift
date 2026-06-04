import SwiftUI

struct OnboardingPageView: View {

    let page: OnboardingPage
    let index: Int

    var body: some View {
        VStack(spacing: MindMorySpacing.xxxl) {
            illustrationView
                .frame(height: 360)
                .padding(.top, MindMorySpacing.xl)

            titleText

            Spacer(minLength: 0)
        }
    }

    private var illustrationView: some View {
        OnboardingIllustrationView(index: index)
            .padding(MindMorySpacing.md)
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

private struct OnboardingIllustrationView: View {

    let index: Int

    var body: some View {
        switch index {
        case 0:
            MomentIllustration()

        case 1:
            ReminderWidgetIllustration()

        default:
            MemoryPageIllustration()
        }
    }
}

private struct MomentIllustration: View {

    var body: some View {
        MemoryImagePlaceholderView(imageName: "friends")
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MindMoryRadius.extraLarge,
                    style: .continuous
                )
            )
            .padding(.horizontal, MindMorySpacing.xl)
    }
}

private struct ReminderWidgetIllustration: View {

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge)
                .fill(MindMoryColors.surfaceStrong)

            VStack(spacing: MindMorySpacing.lg) {
                notificationCard
                lockScreenCard
            }
            .padding(MindMorySpacing.xl)
        }
        .padding(.horizontal, MindMorySpacing.xl)
    }

    private var notificationCard: some View {
        AppCard {
            HStack(spacing: MindMorySpacing.md) {
                IconBadgeView(systemName: "sparkles")

                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("MindMory")
                        .font(MindMoryTypography.bodyMedium)
                        .bold()

                    Text("Good moments don’t last forever.\nThis one might be worth remembering.")
                        .font(MindMoryTypography.bodySmall)
                }

                Spacer()

                MemoryImagePlaceholderView(imageName: "small")
                    .frame(width: 54, height: 54)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
            }
        }
    }

    private var lockScreenCard: some View {
        AppCard {
            HStack {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Monday, May 12")
                        .font(MindMoryTypography.caption)

                    Text("9:41")
                        .font(.system(size: 56, weight: .light))

                    Text("Aroma Coffee\nToday, 10:23 AM")
                        .font(MindMoryTypography.bodySmall)
                }

                Spacer()

                Text("3\nMoments\nthis week")
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.deepGreen)
            }
        }
    }
}

private struct MemoryPageIllustration: View {

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                topBar
                titleText
                HomeMemoryFrameView(memory: PreviewData.aromaMemory, compact: true)
                embeddedTabBar
            }
        }
        .padding(.horizontal, MindMorySpacing.xl)
    }

    private var topBar: some View {
        HStack {
            Text("Good evening ✨")
                .font(MindMoryTypography.caption)

            Spacer()

            Image(systemName: "square.and.arrow.up")
            Image(systemName: "star")
        }
    }

    private var titleText: some View {
        Text("Here’s your moment\nto remember.")
            .font(MindMoryTypography.headingMedium)
    }

    private var embeddedTabBar: some View {
        HStack {
            Text("Home")
            Spacer()
            Text("Album")
            Spacer()
            Text("Settings")
        }
        .font(MindMoryTypography.tabLabel)
        .foregroundStyle(MindMoryColors.primaryGreen)
    }
}
