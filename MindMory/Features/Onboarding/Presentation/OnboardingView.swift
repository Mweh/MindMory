import SwiftUI

struct OnboardingView: View {

    @StateObject var viewModel: OnboardingViewModel

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            MindMoryColors.background
                .ignoresSafeArea()

            onboardingLeafBackground

            contentView
        }
    }

    @ViewBuilder
    private var onboardingLeafBackground: some View {
//        if viewModel.currentIndex == 0 {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Image("element-leaf")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .padding(.trailing, 0)
                }
                .padding(.bottom, 140)
            }
            .ignoresSafeArea()
            .accessibilityHidden(true)
//        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .showingPage:
            onboardingPagesView

        case .permissionEducation:
            PermissionEducationView(
                enableAction: viewModel.permissionsEnabled,
                laterAction: viewModel.maybeLaterTapped
            )
            .padding(MindMorySpacing.xl)

        case .completed:
            Color.clear
                .onAppear(perform: onComplete)
        }
    }

    private var onboardingPagesView: some View {
        VStack(spacing: MindMorySpacing.xl) {
            TabView(
                selection: Binding(
                    get: { viewModel.currentIndex },
                    set: { viewModel.pageChanged(to: $0) }
                )
            ) {
                ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(
                        page: page,
                        index: index
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            PageDots(
                count: viewModel.pages.count,
                selectedIndex: viewModel.currentIndex
            )

            PrimaryButton(
                title: viewModel.pages[viewModel.currentIndex].buttonTitle,
                action: viewModel.continueTapped
            )
            .padding(.horizontal, MindMorySpacing.xl)
        }
        .padding(.bottom, MindMorySpacing.xl)
    }
}

private struct PageDots: View {

    let count: Int
    let selectedIndex: Int

    var body: some View {
        HStack(spacing: MindMorySpacing.xs) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: 10, height: 10)
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        index == selectedIndex ? MindMoryColors.primaryGreen : MindMoryColors.border
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(
            pages: PreviewData.onboardingPages
        ),
        onComplete: {}
    )
}
