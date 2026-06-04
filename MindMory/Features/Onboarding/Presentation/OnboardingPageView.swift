import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    var body: some View {
        VStack(spacing: MindMorySpacing.xxxl) {
            OnboardingIllustrationView(index: index)
                .frame(height: 360)
                .padding(.top, MindMorySpacing.xl)
            Text(page.title)
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, MindMorySpacing.xxl)
            Spacer(minLength: 0)
        }
    }
}

private struct OnboardingIllustrationView: View {
    let index: Int
    var body: some View {
        Group { if index == 0 { MomentIllustration() } else if index == 1 { ReminderWidgetIllustration() } else { MemoryPageIllustration() } }
            .padding(MindMorySpacing.md)
    }
}

private struct MomentIllustration: View {
    var body: some View { MemoryImagePlaceholderView(imageName: "friends").clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)).padding(.horizontal, MindMorySpacing.xl) }
}
private struct ReminderWidgetIllustration: View {
    var body: some View {
        ZStack { RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge).fill(MindMoryColors.surfaceStrong)
            VStack(spacing: MindMorySpacing.lg) { AppCard { HStack { IconBadgeView(systemName: "sparkles"); VStack(alignment:.leading){ Text("MindMory").font(MindMoryTypography.bodyMedium).bold(); Text("Good moments don’t last forever.\nThis one might be worth remembering.").font(MindMoryTypography.bodySmall) }; Spacer(); MemoryImagePlaceholderView(imageName:"small").frame(width:54,height:54).clipShape(RoundedRectangle(cornerRadius:10)) } }
                AppCard { HStack { VStack(alignment:.leading){ Text("Monday, May 12").font(MindMoryTypography.caption); Text("9:41").font(.system(size:56,weight:.light)); Text("Aroma Coffee\nToday, 10:23 AM").font(MindMoryTypography.bodySmall) }; Spacer(); Text("3\nMoments\nthis week").font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.deepGreen) } } }
            .padding(MindMorySpacing.xl) }
        .padding(.horizontal, MindMorySpacing.xl)
    }
}
private struct MemoryPageIllustration: View {
    var body: some View { AppCard { VStack(alignment:.leading, spacing: MindMorySpacing.md){ HStack{Text("Good evening ✨").font(MindMoryTypography.caption); Spacer(); Image(systemName:"square.and.arrow.up"); Image(systemName:"star")}; Text("Here’s your moment\nto remember.").font(MindMoryTypography.headingMedium); HomeMemoryFrameView(memory: PreviewData.aromaMemory, compact: true); HStack{Text("Home"); Spacer(); Text("Album"); Spacer(); Text("Settings")}.font(MindMoryTypography.tabLabel).foregroundStyle(MindMoryColors.primaryGreen)}}.padding(.horizontal, MindMorySpacing.xl) }
}
