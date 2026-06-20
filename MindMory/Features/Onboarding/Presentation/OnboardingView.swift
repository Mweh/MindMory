import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct OnboardingView: View {

    @StateObject var viewModel: OnboardingViewModel
    @Environment(\.openURL) private var openURL

    let onComplete: () -> Void

    var body: some View {
        PageLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.xl,
                leading: MindMorySpacing.xl,
                bottom: MindMorySpacing.xl,
                trailing: MindMorySpacing.xl
            ),
            scrollable: false,
            background: {
                MindMoryColors.Surface.backgroundGradient
                    .ignoresSafeArea()
            }
        ) {
            contentView
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .showingPage:
            onboardingPagesView

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
            .allowsHitTesting(!viewModel.isProcessingPermission)

            PageDots(
                count: viewModel.pages.count,
                selectedIndex: viewModel.currentIndex
            )

            PrimaryButton(
                title: "Continue",
                action: {
                    Task {
                        await viewModel.continueTapped()
                    }
                }
            )
            .disabled(viewModel.isProcessingPermission)
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
        index == selectedIndex ? MindMoryColors.Surface.primary : MindMoryColors.Border.subtle
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(
            pages: OnboardingPageCatalog.pages,
            requestLocationPermissionUseCase: RequestLocationPermissionUseCase(repository: MockPermissionRepository()),
            requestCalendarPermissionUseCase: RequestCalendarPermissionUseCase(repository: MockPermissionRepository()),
            requestNotificationPermissionUseCase: RequestNotificationPermissionUseCase(repository: MockPermissionRepository())
        ),
        onComplete: {}
    )
}
