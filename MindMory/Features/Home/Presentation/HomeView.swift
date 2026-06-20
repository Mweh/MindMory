import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("hasSeenTooltip") private var hasSeenTooltip = false
    @State private var cardFrame: CGRect = .zero

    var body: some View {
        CustomMemoriesLayout(
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
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.retryContextualDiscovery()
            }
        }
        .onPreferenceChange(CardFrameKey.self) { frame in
            cardFrame = frame
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
        switch viewModel.photoState {
        case .idle:
            idleStateView
        case .loading:
            loadingCard
            if let memory = viewModel.focusedMemory {
                homeCard(for: memory)
            }
        case .permissionRequired(.photoLibrary):
            NoPermissionStateView(
                title: "Allow photo access",
                subtitle: "Let MindMory show a nearby photo from your gallery.",
                buttonTitle: "Allow Access",
                iconName: "photo.on.rectangle.angled",
                action: viewModel.didTapAllowAccess
            )
        case .permissionDenied(.photoLibrary):
            NoPermissionStateView(
                title: "Photo access denied",
                subtitle: "Open Settings to grant photo permission so MindMory can surface nearby memories.",
                buttonTitle: "Open Settings",
                iconName: "photo.on.rectangle.angled",
                action: openSettings
            )
        case .permissionDenied(.location):
            NoPermissionStateView(
                title: "Location access denied",
                subtitle: "Open Settings to grant location access so MindMory can find nearby memories.",
                buttonTitle: "Open Settings",
                iconName: "location.fill",
                action: openSettings
            )
        case .permissionRequired(.location):
            NoPermissionStateView(
                title: "Enable location access",
                subtitle: "Allow access so MindMory can surface a nearby photo from your current location.",
                buttonTitle: "Allow Access",
                iconName: "location.fill",
                action: viewModel.didTapAllowAccess
            )
        case .empty(let title, let subtitle):
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                ContextualMemoryEmptyStateView(
                    title: title,
                    subtitle: subtitle
                )

                locationPhotoSections(for: viewModel.photoState)
            }
        case .error(let message):
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                ErrorStateView(message: message, retryAction: viewModel.retryContextualDiscovery)

                locationPhotoSections(for: viewModel.photoState)
            }
        case .loaded:
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                if let memory = viewModel.focusedMemory {
                    favoriteHeader
                    homeCard(for: memory)
                } else {
                    ContextualMemoryEmptyStateView(
                        title: "No favorite nearby photo",
                        subtitle: "MindMory is still showing nearby photos for this location."
                    )
                }

                locationPhotoSections(for: viewModel.photoState)
            }
        }
    }

    @ViewBuilder
    private func homeCard(for memory: Memory) -> some View {
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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(viewModel.headerCopy.title)
                .font(MindMoryTypography.displayLevel)
                .foregroundStyle(MindMoryColors.Content.inverse)
                .fixedSize(horizontal: false, vertical: true)

            Text(viewModel.headerCopy.subtitle)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.inverseSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var favoriteHeader: some View {
        Text("Flip the card to revisit a moment that matches your current location.")
            .font(MindMoryTypography.bodyMedium)
            .foregroundStyle(MindMoryColors.Content.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func locationPhotoSections(for photoState: HomePhotoState) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            SectionTitle(
                title: "Recent captures",
                description: "Latest photos taken within 1 km of your current location.",
                size: .medium
            )

            switch photoState {
            case .loading, .idle:
                loadingRecentPhotoSection
            case .permissionRequired, .permissionDenied:
                recentPhotoSection(for: [], debugPlaceholderCount: viewModel.qaDebugPlaceholderCount)
            case .empty:
                ContextualMemoryEmptyStateView(
                    title: "No recent nearby photos available.",
                    subtitle: "Try moving closer to a place where you took a photo."
                )
            case .error:
                ErrorStateView(
                    message: "Recent photos could not be loaded.",
                    retryAction: viewModel.retryContextualDiscovery
                )
            case .loaded:
                recentPhotoSection(for: viewModel.recentPhotoAssetIdentifiers, debugPlaceholderCount: viewModel.qaDebugPlaceholderCount)
            }

            SectionTitle(
                title: "Captures with people",
                description: "Photos within 1 km from your current location that contain people.",
                size: .medium
            )

            switch photoState {
            case .loading, .idle:
                loadingRecentPhotoSection
            case .permissionRequired, .permissionDenied:
                recentPhotoSection(for: [], debugPlaceholderCount: viewModel.qaDebugPlaceholderCount)
            case .empty:
                ContextualMemoryEmptyStateView(
                    title: "No nearby people captures.",
                    subtitle: "Try moving closer to a place where you took a photo with people."
                )
            case .error:
                ErrorStateView(
                    message: "Filtered photos could not be loaded.",
                    retryAction: viewModel.retryContextualDiscovery
                )
            case .loaded:
                recentPhotoSection(for: viewModel.peoplePhotoAssetIdentifiers, debugPlaceholderCount: viewModel.qaDebugPlaceholderCount)
            }
        }
    }

    private var loadingRecentPhotoSection: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                ImagePlaceholder(imageName: nil)
                    .frame(width: 132, height: 132)
                    .redacted(reason: .placeholder)
            }
        }
        .padding(.vertical, MindMorySpacing.sm)
    }

    @ViewBuilder
    private func recentPhotoSection(for assetIdentifiers: [String], debugPlaceholderCount: Int = 0) -> some View {
        if debugPlaceholderCount > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(0..<debugPlaceholderCount, id: \.self) { _ in
                        ImagePlaceholder(imageName: nil)
                            .frame(width: 132, height: 132)
                    }
                }
                .padding(.vertical, MindMorySpacing.sm)
            }
        } else if assetIdentifiers.isEmpty {
            ContextualMemoryEmptyStateView(
                title: "No recent nearby photos available.",
                subtitle: "Try moving closer to a place where you took a photo."
            )
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(Array(assetIdentifiers.prefix(3)), id: \.self) { identifier in
                        ContextualMemoryAssetImageView(assetLocalIdentifier: identifier)
                            .frame(width: 132, height: 132)
                    }
                }
                .padding(.vertical, MindMorySpacing.sm)
            }
        }
    }

    private func openSettings() {
#if canImport(UIKit)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(settingsURL)
#endif
    }

    private var idleStateView: some View {
        ContextualMemoryEmptyStateView(
            title: "Checking permissions...",
            subtitle: "MindMory is verifying location and photo access before showing nearby memories.",
            systemImage: "hourglass"
        )
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
