import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct OnboardingView: View {

    @StateObject var viewModel: OnboardingViewModel
    @Environment(\.openURL) private var openURL

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            MindMoryColors.Surface.background
                .ignoresSafeArea()

            onboardingLeafBackground

            contentView
        }
        .alert(
            alertTitle,
            isPresented: Binding(
                get: { viewModel.activeAlert != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissPermissionAlert()
                    }
                }
            ),
            presenting: viewModel.activeAlert
        ) { alert in
            if settingsURL != nil {
                Button("Open Settings") {
                    openSettings()
                }
            }

            Button("Continue") {
                viewModel.continueAfterPermissionAlert()
            }
        } message: { alert in
            Text(alertMessage(for: alert))
        }
    }

    @ViewBuilder
    private var onboardingLeafBackground: some View {
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

    private var alertTitle: String {
        "Permission Needed"
    }

    private var settingsURL: URL? {
#if canImport(UIKit)
        URL(string: UIApplication.openSettingsURLString)
#else
        nil
#endif
    }

    private func openSettings() {
        guard let settingsURL else {
            viewModel.dismissPermissionAlert()
            return
        }

        openURL(settingsURL)
        viewModel.dismissPermissionAlert()
    }

    private func alertMessage(for alert: OnboardingAlert) -> String {
        switch alert {
        case let .permissionDenied(permission):
            return permission.deniedMessage
        }
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
