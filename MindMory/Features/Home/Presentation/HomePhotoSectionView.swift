import SwiftUI

struct HomePhotoSectionView: View {
    let title: String
    let subtitle: String
    let descriptionText: String?
    let assetIdentifiers: [String]
    let photoState: HomePhotoState
    let debugPlaceholderCount: Int
    let imageSize: CGSize
    let bodySpacing: CGFloat
    let headerBottomSpacing: CGFloat
    let contentTopPadding: CGFloat
    let emptyTitle: String
    let emptySubtitle: String
    let errorMessage: String
    let retryAction: (() -> Void)?
    let isCarousel: Bool
    let showPictureTakenOverlay: Bool

    @State private var selectedIndex = 0

    init(
        title: String,
        subtitle: String,
        assetIdentifiers: [String],
        photoState: HomePhotoState,
        debugPlaceholderCount: Int = 0,
        imageSize: CGSize = CGSize(width: 132, height: 132),
        bodySpacing: CGFloat = MindMorySpacing.md,
        headerBottomSpacing: CGFloat = MindMorySpacing.xs,
        contentTopPadding: CGFloat = MindMorySpacing.xs,
        emptyTitle: String,
        emptySubtitle: String,
        errorMessage: String,
        isCarousel: Bool = false,
        showPictureTakenOverlay: Bool = false,
        descriptionText: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.descriptionText = descriptionText
        self.assetIdentifiers = assetIdentifiers
        self.photoState = photoState
        self.debugPlaceholderCount = debugPlaceholderCount
        self.imageSize = imageSize
        self.bodySpacing = bodySpacing
        self.headerBottomSpacing = headerBottomSpacing
        self.contentTopPadding = contentTopPadding
        self.emptyTitle = emptyTitle
        self.emptySubtitle = emptySubtitle
        self.errorMessage = errorMessage
        self.isCarousel = isCarousel
        self.showPictureTakenOverlay = showPictureTakenOverlay
        self.retryAction = retryAction
    }

    var body: some View {
        VStack(alignment: .leading, spacing: bodySpacing) {
            sectionHeader
                .zIndex(1)
            sectionContent
            sectionDescription
        }
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch photoState {
        case .loading, .idle:
            loadingPhotoSection
        case .permissionRequired, .permissionDenied:
            photoGridSection(for: [], debugPlaceholderCount: debugPlaceholderCount)
        case .empty(_,_):
            ContextualMemoryEmptyStateView(title: emptyTitle, subtitle: emptySubtitle)
        case .error:
            ErrorStateView(message: errorMessage, retryAction: retryAction)
        case .loaded:
            photoGridSection(for: assetIdentifiers, debugPlaceholderCount: debugPlaceholderCount)
        }
    }

    @ViewBuilder
    private var sectionDescription: some View {
        if let descriptionText, !descriptionText.isEmpty {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text(descriptionText)
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
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .stroke(MindMoryColors.Content.inverse, lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor.opacity(0.16), radius: 14, x: 0, y: 6)
            .overlay(
                Text("Message for you")
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .stroke(MindMoryColors.Content.primary, lineWidth: 1)
                    )
                    .shadow(color: MindMoryShadow.cardColor.opacity(0.12), radius: 8, x: 0, y: 4)
                    .offset(x: MindMorySpacing.sm, y: -MindMorySpacing.sm),
                alignment: .topTrailing
            )
            .padding(.top, MindMorySpacing.lg)
        }
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text(title)
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(MindMoryTypography.bodyMedium)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }
                }

                Spacer()

                if isCarousel {
                    HStack(spacing: MindMorySpacing.xs) {
                        Button(action: goToPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(selectedIndex == 0 ? MindMoryColors.Content.secondary : MindMoryColors.Content.primary)
                                .frame(width: 44, height: 44)
                                .background(MindMoryColors.Surface.surface)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .padding(4)
                        .disabled(selectedIndex == 0 || assetIdentifiers.isEmpty)
                        .opacity(selectedIndex == 0 || assetIdentifiers.isEmpty ? 0.4 : 1)

                        Button(action: goToNext) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(selectedIndex == assetIdentifiers.count - 1 ? MindMoryColors.Content.secondary : MindMoryColors.Content.primary)
                                .frame(width: 44, height: 44)
                                .background(MindMoryColors.Surface.surface)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .padding(4)
                        .disabled(assetIdentifiers.isEmpty || selectedIndex == assetIdentifiers.count - 1)
                        .opacity(assetIdentifiers.isEmpty || selectedIndex == assetIdentifiers.count - 1 ? 0.4 : 1)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, headerBottomSpacing)
        .zIndex(1)
    }

    private var loadingPhotoSection: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ForEach(0..<3, id: \.self) { _ in
                ImagePlaceholder(imageName: nil)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .redacted(reason: .placeholder)
            }
        }
    }

    @ViewBuilder
    private func photoGridSection(for assetIdentifiers: [String], debugPlaceholderCount: Int) -> some View {
        if debugPlaceholderCount > 0 {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(0..<debugPlaceholderCount, id: \.self) { _ in
                        ImagePlaceholder(imageName: nil)
                            .frame(width: imageSize.width, height: imageSize.height)
                    }
                }
            }
        } else if assetIdentifiers.isEmpty {
            ContextualMemoryEmptyStateView(title: emptyTitle, subtitle: emptySubtitle)
        } else if isCarousel {
            photoCarouselSection(for: assetIdentifiers)
                .padding(.top, contentTopPadding)
        } else {
            horizontalPhotoList(for: assetIdentifiers)
        }
    }

    private func photoCarouselSection(for assetIdentifiers: [String]) -> some View {
        let imageHeight: CGFloat = 220
        let cardHeight: CGFloat = imageHeight + 16
        let maxVerticalOffset: CGFloat = 16
        let visibleHeight = cardHeight + maxVerticalOffset
        let itemSpacing: CGFloat = -24

        return VStack(spacing: 0) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let cardWidth = min(340, width * 0.9)

                HStack(spacing: itemSpacing) {
                    ForEach(assetIdentifiers.indices, id: \.self) { index in
                        let identifier = assetIdentifiers[index]
                        let isOddCard = !index.isMultiple(of: 2)
                        photoCard(
                            for: identifier,
                            width: cardWidth,
                            imageHeight: imageHeight,
                            verticalOffset: isOddCard ? maxVerticalOffset : 0
                        )
                        .rotationEffect(.degrees(cardRotationAngle(for: index, selectedIndex: selectedIndex)))
                        .zIndex(index == selectedIndex ? 2 : 1)
                    }
                }
                .offset(x: -CGFloat(selectedIndex) * (cardWidth + itemSpacing))
                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.85, blendDuration: 0), value: selectedIndex)
                .frame(width: width, height: visibleHeight, alignment: .leading)
            }
            .frame(height: visibleHeight)
        }
        .onChange(of: assetIdentifiers) {
            selectedIndex = min(selectedIndex, max(assetIdentifiers.count - 1, 0))
        }
    }

    private func photoCard(for assetIdentifier: String, width: CGFloat, imageHeight: CGFloat, verticalOffset: CGFloat) -> some View {
        let cardShape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        return ContextualMemoryAssetImageView(assetLocalIdentifier: assetIdentifier)
            .frame(maxWidth: .infinity)
            .frame(height: imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.28)]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            )
            .padding(MindMorySpacing.xs)
            .background(MindMoryColors.Surface.elevated)
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(MindMoryColors.Border.subtle.opacity(0.75), lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor.opacity(0.16), radius: 18, x: 0, y: 12)
            .frame(width: width)
            .offset(y: verticalOffset)
    }

    private func cardRotationAngle(for index: Int, selectedIndex: Int) -> Double {
        guard index != selectedIndex else { return 0 }
        let angles: [Double] = [-5, -3, 3, 5]
        let stableIndex = abs((index - selectedIndex) * 7) % angles.count
        return angles[stableIndex]
    }

    private func horizontalPhotoList(for assetIdentifiers: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                ForEach(assetIdentifiers, id: \.self) { identifier in
                    ContextualMemoryAssetImageView(assetLocalIdentifier: identifier)
                        .frame(width: imageSize.width, height: imageSize.height)
                }
            }
        }
    }

    private func goToPrevious() {
        guard selectedIndex > 0 else { return }
        selectedIndex -= 1
    }

    private func goToNext() {
        guard selectedIndex < assetIdentifiers.count - 1 else { return }
        selectedIndex += 1
    }
}

struct HomePhotoSectionView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: MindMorySpacing.lg) {
            HomePhotoSectionView(
                title: "Recent captures",
                subtitle: "Latest photos taken within 1 km of your current location.",
                assetIdentifiers: ["1", "2", "3"],
                photoState: .loaded,
                debugPlaceholderCount: 0,
                emptyTitle: "No recent nearby photos available.",
                emptySubtitle: "Try moving closer to a place where you took a photo.",
                errorMessage: "Recent photos could not be loaded.",
                retryAction: {}
            )

            HomePhotoSectionView(
                title: "Faces Along the Way",
                subtitle: "Photos within 1 km from your current location that contain people.",
                assetIdentifiers: [],
                photoState: .empty(
                    title: "No nearby people captures.",
                    subtitle: "Try moving closer to a place where you took a photo with people."
                ),
                debugPlaceholderCount: 0,
                emptyTitle: "No nearby people captures.",
                emptySubtitle: "Try moving closer to a place where you took a photo with people.",
                errorMessage: "Filtered photos could not be loaded.",
                retryAction: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
