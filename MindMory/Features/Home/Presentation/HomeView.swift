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
            ContextualMemoryEmptyStateView(
                title: title,
                subtitle: subtitle
            )
        case .error(let message):
            ErrorStateView(message: message, retryAction: viewModel.retryContextualDiscovery)
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

                locationPhotoSections
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
        SectionTitle(
            title: "Current memory spotlight",
            description: "Flip the card to revisit a moment that matches your current location.",
            size: .medium
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var locationPhotoSections: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            if !viewModel.peoplePhotoAssetIdentifiers.isEmpty {
                SectionTitle(
                    title: "People nearby",
                    description: "Photos from this location that include people.",
                    size: .medium
                )
                recentPhotoRow(for: viewModel.peoplePhotoAssetIdentifiers, placeholderText: "No people photos found nearby.")
            }

            if !viewModel.recentPhotoAssetIdentifiers.isEmpty {
                SectionTitle(
                    title: "Recent captures",
                    description: "Latest photos taken within 1 km of your current location.",
                    size: .medium
                )
                recentPhotoRow(for: viewModel.recentPhotoAssetIdentifiers, placeholderText: "No recent nearby photos available.")
            }
        }
    }

    private func recentPhotoRow(for assetIdentifiers: [String], placeholderText: String) -> some View {
        if assetIdentifiers.isEmpty {
            return AnyView(
                ContextualMemoryEmptyStateView(
                    title: placeholderText,
                    subtitle: "Try moving closer to a place where you took a photo."
                )
            )
        }

        return AnyView(
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(assetIdentifiers, id: \.self) { identifier in
                        ContextualMemoryAssetImageView(assetLocalIdentifier: identifier)
                            .frame(width: 132, height: 132)
                    }
                }
                .padding(.vertical, MindMorySpacing.sm)
            }
        )
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
