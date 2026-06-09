import SwiftUI

// MARK: - Animated Text Section View Extension
extension MemoryAlbumTextSectionRenderView {
    func withAnimations(delay: Double = 0) -> some View {
        AnimatedTextSectionView(textSection: textSection, isPreview: isPreview, delay: delay)
    }
}

// MARK: - Animated Text Section Render View
struct AnimatedTextSectionView: View {
    let textSection: MemoryAlbumTextSection
    var isPreview: Bool = false
    let delay: Double
    
    @State private var titleVisible = false
    @State private var descriptionVisible = false
    @State private var titleTriggered = false
    @State private var descriptionTriggered = false

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: combinedAlignment)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var content: some View {
        VStack(alignment: stackHorizontalAlignment, spacing: MindMorySpacing.xs) {
            if textSection.blockType == .titleAndDescription {
                if textSection.isTitleFirst {
                    titleViewWithDetection
                    descriptionViewWithDetection
                } else {
                    descriptionViewWithDetection
                    titleViewWithDetection
                }
            } else if textSection.blockType == .titleOnly {
                titleViewWithDetection
            } else {
                descriptionViewWithDetection
            }
        }
        .frame(maxWidth: .infinity, alignment: frameHorizontalAlignment)
    }
    
    private var titleViewWithDetection: some View {
        titleView
            .opacity(titleVisible ? 1 : 0)
            .offset(x: titleVisible ? 0 : -15)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkTitleVisibility(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkTitleVisibility(geometry)
                        }
                }
            )
    }
    
    private var descriptionViewWithDetection: some View {
        descriptionView
            .opacity(descriptionVisible ? 1 : 0)
            .offset(x: descriptionVisible ? 0 : -15)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkDescriptionVisibility(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkDescriptionVisibility(geometry)
                        }
                }
            )
    }
    
    private func checkTitleVisibility(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !titleTriggered {
            titleTriggered = true
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                titleVisible = true
            }
        }
    }
    
    private func checkDescriptionVisibility(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !descriptionTriggered {
            descriptionTriggered = true
            withAnimation(.easeOut(duration: 0.6).delay(delay + 0.1)) {
                descriptionVisible = true
            }
        }
    }

    private var titleView: some View {
        Text(textSection.title)
            .font(.system(size: textSection.style.titleSize, weight: textSection.style.titleWeight.fontWeight, design: .serif))
            .foregroundStyle(MindMoryColors.textPrimary)
            .multilineTextAlignment(multilineAlignment)
            .frame(maxWidth: .infinity, alignment: frameHorizontalAlignment)
            .lineLimit(isPreview ? 2 : nil)
    }

    private var descriptionView: some View {
        Text(textSection.description)
            .font(.system(size: textSection.style.descriptionSize, weight: textSection.style.descriptionWeight.fontWeight, design: .default))
            .foregroundStyle(MindMoryColors.textSecondary)
            .multilineTextAlignment(multilineAlignment)
            .frame(maxWidth: .infinity, alignment: frameHorizontalAlignment)
            .lineLimit(isPreview ? 3 : nil)
    }

    private var combinedAlignment: Alignment {
        switch (textSection.verticalAlignment, textSection.horizontalAlignment) {
        case (.top, .leading):
            return .topLeading
        case (.top, .center):
            return .top
        case (.top, .trailing):
            return .topTrailing
        case (.center, .leading):
            return .leading
        case (.center, .center):
            return .center
        case (.center, .trailing):
            return .trailing
        case (.bottom, .leading):
            return .bottomLeading
        case (.bottom, .center):
            return .bottom
        case (.bottom, .trailing):
            return .bottomTrailing
        }
    }

    private var frameHorizontalAlignment: Alignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    private var stackHorizontalAlignment: HorizontalAlignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }

    private var multilineAlignment: TextAlignment {
        switch textSection.horizontalAlignment {
        case .leading:
            return .leading
        case .center:
            return .center
        case .trailing:
            return .trailing
        }
    }
}
