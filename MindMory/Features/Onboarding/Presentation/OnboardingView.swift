import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        ZStack {
            MindMoryColors.background.ignoresSafeArea()
            switch viewModel.state {
            case .showingPage:
                VStack(spacing: MindMorySpacing.xl) {
                    TabView(selection: Binding(get: { viewModel.currentIndex }, set: { _ in })) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                            OnboardingPageView(page: page, index: index).tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    PageDots(count: viewModel.pages.count, selectedIndex: viewModel.currentIndex)
                    PrimaryButton(title: viewModel.pages[viewModel.currentIndex].buttonTitle, action: viewModel.continueTapped)
                        .padding(.horizontal, MindMorySpacing.xl)
                }
                .padding(.bottom, MindMorySpacing.xl)
            case .permissionEducation:
                PermissionEducationView(enableAction: viewModel.permissionsEnabled, laterAction: viewModel.maybeLaterTapped)
                    .padding(MindMorySpacing.xl)
            case .completed:
                Color.clear.onAppear(perform: onComplete)
            }
        }
    }
}

private struct PageDots: View { let count:Int; let selectedIndex:Int; var body: some View { HStack(spacing: MindMorySpacing.xs){ ForEach(0..<count,id:\.self){ Circle().fill($0==selectedIndex ? MindMoryColors.primaryGreen : MindMoryColors.border).frame(width:10,height:10)}}}}

#Preview { OnboardingView(viewModel: OnboardingViewModel(pages: PreviewData.onboardingPages), onComplete: {}) }
