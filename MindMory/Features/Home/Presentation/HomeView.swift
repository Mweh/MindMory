import SwiftUI
import UIKit
import Photos

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

                locationSummaryCards

                if let memory = viewModel.focusedMemory {
                    homeCard(for: memory)
                }

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
            // NOTE: CardFrameKey is still used but as a fallback.
            // Primary frame capture is done via onGeometryChange inside homeCard.
            if cardFrame == .zero { cardFrame = frame }
        }
        .overlay {
            // Show as soon as there is a visible card on front side.
            // cardFrame is used only for spotlight position — not to gate visibility.
            let cardIsVisible = viewModel.photoState == .loaded
                && viewModel.focusedMemory != nil
                && viewModel.cardSide == .front

            if !hasSeenTooltip && cardIsVisible {
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
            VStack(alignment: .leading, spacing: MindMorySpacing.xxl) {
                if viewModel.focusedMemory == nil {
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
        // Use onGeometryChange to directly write the frame, bypassing ScrollView
        // which swallows PreferenceKey propagation.
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear {
                        cardFrame = geo.frame(in: .global)
                    }
                    .onChange(of: geo.frame(in: .global)) { _, newFrame in
                        cardFrame = newFrame
                    }
            }
        )
        // Keep PreferenceKey as a secondary mechanism
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
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Your memories")
                .font(MindMoryTypography.displayLevel)
                .foregroundStyle(MindMoryColors.Content.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            (
                Text("Showing nearby photos from ") +
                Text(viewModel.currentLocationName ?? "your current location")
                    .fontWeight(.semibold) +
                Text(".")
            )
            .font(MindMoryTypography.bodyMedium)
            .foregroundStyle(MindMoryColors.Content.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var locationSummaryCards: some View {
        HStack(spacing: MindMorySpacing.md) {
            lastPhotoCard
            totalPhotosCard
        }
        .frame(maxWidth: .infinity)
    }

    private var lastPhotoCard: some View {
        let cardShape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        return ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text("Last photo here")
                    .font(MindMoryTypography.titleSmall)
                    .foregroundStyle(MindMoryColors.Content.inverseSecondary)

                Text(viewModel.latestNearbyPhotoDateText ?? "No recent photo")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.inverse)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(MindMorySpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                cardShape.fill(MindMoryColors.Surface.primary)
            )
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(MindMoryColors.Border.subtle.opacity(0.75), lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor.opacity(0.16), radius: 18, x: 0, y: 12)

            Circle()
                .fill(MindMoryColors.Surface.elevated)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "camera.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(MindMoryColors.Content.primary)
                        .rotationEffect(.degrees(-15))
                )
                .overlay(
                    Circle()
                        .stroke(MindMoryColors.Content.primary, lineWidth: 1)
                )
                .shadow(color: MindMoryShadow.cardColor.opacity(0.12), radius: 6, x: 0, y: 4)
                .offset(x: MindMorySpacing.xs, y: -MindMorySpacing.sm)
        }
        .frame(maxWidth: .infinity)
    }

    private var totalPhotosCard: some View {
        let cardShape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        return VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text("Total photos")
                .font(MindMoryTypography.titleSmall)
                .foregroundStyle(MindMoryColors.Content.inverseSecondary)

            Text("\(viewModel.nearbyPhotoCount)")
                .font(MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Content.inverse)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: true)
        }
        .padding(MindMorySpacing.lg)
        .background(
            cardShape.fill(MindMoryColors.Surface.primary)
        )
        .clipShape(cardShape)
        .overlay(
            cardShape.stroke(MindMoryColors.Border.subtle.opacity(0.75), lineWidth: 1)
        )
        .shadow(color: MindMoryShadow.cardColor.opacity(0.12), radius: 12, x: 0, y: 6)
        .fixedSize()
    }

    private var homeMemoryTipCard: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Badge(
                iconName: "sparkles",
                text: "Memory tip",
                tint: MindMoryColors.Content.inverse,
                style: .iconText
            )

            Text("\"Life moves fast. Most moments are forgotten within a week unless we make a home for them.\"")
                .font(MindMoryTypography.titleMedium)
                .foregroundStyle(MindMoryColors.Content.inverse)
                .italic()
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(MindMorySpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(MindMoryColors.Surface.primary)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .shadow(color: MindMoryShadow.cardColor.opacity(0.16), radius: 14, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(MindMoryColors.Content.inverse, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(MindMoryColors.Content.inverse)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundColor(MindMoryColors.Content.primary)
                )
                .overlay(
                    Circle()
                        .stroke(MindMoryColors.Content.primary, lineWidth: 1)
                )
                .shadow(color: MindMoryShadow.cardColor.opacity(0.12), radius: 8, x: 0, y: 4)
                .offset(x: MindMorySpacing.sm, y: -MindMorySpacing.sm)
        }
    }

    private func locationPhotoSections(for photoState: HomePhotoState) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            HomePhotoSectionView(
                title: "Faces Along the Way",
                subtitle: "",
                assetIdentifiers: viewModel.peoplePhotos.map(\.localIdentifier),
                photoState: photoState,
                debugPlaceholderCount: viewModel.qaDebugPlaceholderCount,
                bodySpacing: MindMorySpacing.xxs,
                headerBottomSpacing: 0,
                contentTopPadding: 0,
                emptyTitle: "No nearby people captures.",
                emptySubtitle: "Try moving closer to a place where you took a photo with people.",
                errorMessage: "Filtered photos could not be loaded.",
                isCarousel: true,
                showPictureTakenOverlay: true,
                descriptionText: "\"How beautiful life becomes through the people we meet along the way, turning ordinary moments into lasting memories\"",
                retryAction: viewModel.retryContextualDiscovery
            )

            switch photoState {
            case .loaded:
                if viewModel.recentPhotoAssetIdentifiers.isEmpty {
                    ContextualMemoryEmptyStateView(
                        title: "No recent nearby photos available.",
                        subtitle: "Try moving closer to a place where you took a photo."
                    )
                } else {
                    HomePhotoSectionView(
                        title: "Recent captures",
                        subtitle: "Latest photos taken within 1 km of your current location.",
                        assetIdentifiers: viewModel.recentPhotoAssetIdentifiers,
                        photoState: .loaded,
                        debugPlaceholderCount: viewModel.qaDebugPlaceholderCount,
                        emptyTitle: "No recent nearby photos available.",
                        emptySubtitle: "Try moving closer to a place where you took a photo.",
                        errorMessage: "Recent photos could not be loaded.",
                        isCarousel: true,
                        retryAction: viewModel.retryContextualDiscovery
                    )
                }
            default:
                HomePhotoSectionView(
                    title: "Recent captures",
                    subtitle: "Latest photos taken within 1 km of your current location.",
                    assetIdentifiers: viewModel.recentPhotoAssetIdentifiers,
                    photoState: photoState,
                    debugPlaceholderCount: viewModel.qaDebugPlaceholderCount,
                    emptyTitle: "No recent nearby photos available.",
                    emptySubtitle: "Try moving closer to a place where you took a photo.",
                    errorMessage: "Recent photos could not be loaded.",
                    isCarousel: true,
                    retryAction: viewModel.retryContextualDiscovery
                )
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

private struct TopRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: radius),
            control: CGPoint(x: rect.maxX, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct RoundedCorners: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview { HomeView(viewModel: DependencyContainer().makeHomeViewModel()) }
