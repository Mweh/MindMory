import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @AppStorage("hasSeenTooltip") private var hasSeenTooltip = false
    @State private var cardFrame: CGRect = .zero

    var body: some View {
        PageLayout(
            padding: EdgeInsets(
                top: MindMorySpacing.xl,
                leading: MindMorySpacing.xl,
                bottom: MindMorySpacing.xxl,
                trailing: MindMorySpacing.xl
            )
        ) {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header

                contextualContent
            }
        }
        .navigationBarHidden(true)
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
        .onAppear { viewModel.load() }
        .onPreferenceChange(CardFrameKey.self) { frame in
            cardFrame = frame
        }
        .onChange(of: viewModel.homeCardState) { _, newState in
            if newState != .normal {
                cardFrame = .zero
            }
        }
        .overlay {
            if !hasSeenTooltip && cardFrame != .zero && viewModel.cardSide == .front {
                SpotlightTooltipView(cardFrame: cardFrame) {
                    hasSeenTooltip = true
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $viewModel.isShowingSharePreview) {
            if let memory = viewModel.focusedMemory {
                ShareMemoryPreviewView(
                    memory: memory,
                    imageSource: viewModel.focusedImageSource,
                    captionText: viewModel.captionText,
                    dismissAction: viewModel.dismissSharePreview
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    @ViewBuilder
    private var contextualContent: some View {
        switch viewModel.contextualState {
        case .loading:
            loadingCard
            if let memory = viewModel.focusedMemory {
                favoriteHeader
                homeCard(for: memory)
            }
        case .permissionRequired(.photoLibrary):
            NoPermissionStateView(
                title: "Allow photo access",
                subtitle: "Let MindMory choose an image for a memory from your nearby moments.",
                buttonTitle: "Allow Access",
                iconName: "photo.on.rectangle.angled",
                action: viewModel.didTapAllowAccess
            )
        case .permissionRequired(.calendar):
            NoPermissionStateView(
                title: "Allow calendar access",
                subtitle: "Let MindMory connect memories to events happening now.",
                buttonTitle: "Allow Access",
                iconName: "calendar",
                action: viewModel.didTapAllowAccess
            )
        case .permissionRequired:
            NoPermissionStateView(
                title: "Enable location access",
                subtitle: "Allow access so MindMory can surface a memory tied to your current place.",
                buttonTitle: "Allow Access",
                iconName: "location.fill",
                action: viewModel.didTapAllowAccess
            )
        case .empty:
            ContextualMemoryEmptyStateView(
                title: "No memory has surfaced yet.",
                subtitle: "We’ll keep this screen ready for a moment that matches your location."
            )
        case .error:
            if let errorMessage = viewModel.contextualErrorMessage {
                ErrorStateView(
                    message: errorMessage,
                    retryAction: viewModel.retryContextualDiscovery
                )
            } else {
                ErrorStateView(message: "Something went wrong.", retryAction: viewModel.retryContextualDiscovery)
            }
        case .loaded, .idle:
            if let memory = viewModel.focusedMemory {
                favoriteHeader
                homeCard(for: memory)
            } else {
                ContextualMemoryEmptyStateView(
                    title: "No memory has surfaced yet.",
                    subtitle: "MindMory is ready to match a moment from this location."
                )
            }
        }
    }

    @ViewBuilder
    private func homeCard(for memory: Memory) -> some View {
        switch viewModel.homeCardState {
        case .normal:
            InteractiveMemoryCardView(
                memory: memory,
                imageSource: viewModel.focusedImageSource,
                side: $viewModel.cardSide,
                captionText: $viewModel.captionText,
                flipAction: viewModel.flipCard,
                shareAction: viewModel.showSharePreview
            )
            .overlay(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: CardFrameKey.self,
                        value: geo.frame(in: .global)
                    )
                }
            )
        case .firstReminderPrepared:
            FirstReminderPreparedCardView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: viewModel.headerCopy.title,
                description: viewModel.headerCopy.subtitle,
                size: .large
            )

            locationBanner
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var favoriteHeader: some View {
        SectionTitle(
            title: "Current memory spotlight",
            description: "Flip the card to revisit a moment that matches your current location.",
            size: .medium
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var locationBanner: some View {
        HStack(spacing: MindMorySpacing.md) {
            Image(systemName: "location.fill")
                .foregroundStyle(MindMoryColors.Content.link)
                .font(.system(size: 14, weight: .semibold))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.locationBannerTitle)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text("A memory connected to where you are now")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }

            Spacer()
        }
        .padding(MindMorySpacing.md)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }

    private var loadingCard: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ProgressView()
                .tint(MindMoryColors.Surface.primary)
            Text("Finding a memory connected to this moment…")
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(MindMorySpacing.md)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
