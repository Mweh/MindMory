import SwiftUI
import UIKit

protocol MemoryAlbumLabelable {
    var label: String { get }
}

struct MemoryAlbumSectionCreateView: View {
    @State private var selectedSectionType: MemoryAlbumSectionType = .image
    @State private var selectedLayoutCount: Int = 1
    @State private var selectedMirrorVariants: [Int: Int] = [:]  // [variantId: selectedMirrorVariant]
    @State private var textBlockType: MemoryAlbumTextBlockType = .titleAndDescription
    @State private var textHorizontalAlignment: MemoryAlbumTextHorizontalAlignment = .leading
    @State private var textVerticalAlignment: MemoryAlbumTextVerticalAlignment = .top
    @State private var textIsTitleFirst: Bool = true
    @State private var textTitle: String = ""
    @State private var textDescription: String = ""
    @State private var titleSize: Double = MemoryAlbumTextStyle.default.titleSize
    @State private var descriptionSize: Double = MemoryAlbumTextStyle.default.descriptionSize
    @State private var titleWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.titleWeight
    @State private var descriptionWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.descriptionWeight

    let existingSection: MemoryAlbumSection?
    let onSave: (MemoryAlbumSection) -> Void

    @FocusState private var isTitleFocused: Bool

    init(existingSection: MemoryAlbumSection? = nil, onSave: @escaping (MemoryAlbumSection) -> Void) {
        self.existingSection = existingSection
        self.onSave = onSave

        if let section = existingSection {
            _selectedSectionType = State(initialValue: section.type)

            if case .image(let layoutCount, _, _) = section.content {
                _selectedLayoutCount = State(initialValue: layoutCount)
            }

            if let textSection = section.textSection {
                _textBlockType = State(initialValue: textSection.blockType)
                _textHorizontalAlignment = State(initialValue: textSection.horizontalAlignment)
                _textVerticalAlignment = State(initialValue: textSection.verticalAlignment)
                _textIsTitleFirst = State(initialValue: textSection.isTitleFirst)
                _textTitle = State(initialValue: textSection.title)
                _textDescription = State(initialValue: textSection.description)
                _titleSize = State(initialValue: textSection.style.titleSize)
                _descriptionSize = State(initialValue: textSection.style.descriptionSize)
                _titleWeight = State(initialValue: textSection.style.titleWeight)
                _descriptionWeight = State(initialValue: textSection.style.descriptionWeight)
            }
        }
    }

    var body: some View {
        PageLayout {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                // Context-aware header
                sectionHeader

                // Hide type chips when editing or preconfigured to avoid switching context
                if existingSection == nil {
                    sectionTypeChips
                }

                // Only render the builder matching the current selected type
                if selectedSectionType == .image {
                    imageSectionBuilder
                } else {
                    textSectionBuilder
                }

                Spacer(minLength: MindMorySpacing.xl)
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // If opened with a preconfigured text section, focus the title input to speed up entry
            if existingSection?.type == .text {
                DispatchQueue.main.async {
                    isTitleFocused = true
                }
            }
        }
    }

    private var imageSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            layoutChips

                Text("Pick a layout for your image section. Choose from horizontal, vertical, and mixed arrangements to match your story.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)

            layoutOptions
        }
    }

    private var textSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            Text("Customize text section")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.primary)

            textTypeControls
            typographyControls

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Preview")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.primary)

                MemoryAlbumTextSectionRenderView(textSection: configuredTextSection, isPreview: true)
                    .frame(height: 180)
            }

            PrimaryButton(title: existingSection == nil ? "Add Text Section" : "Save Section") {
                onSave(
                    MemoryAlbumSection(
                        id: existingSection?.id ?? UUID(),
                        textSection: configuredTextSection
                    )
                )
            }
        }
    }

    private var sectionTypeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                FilterChip(title: "Image", systemImage: nil, isSelected: selectedSectionType == .image) {
                    selectedSectionType = .image
                }

                FilterChip(title: "Text", systemImage: nil, isSelected: selectedSectionType == .text) {
                    selectedSectionType = .text
                }
            }
            .padding(.vertical, MindMorySpacing.xs)
        }
    }

    private var textTypeControls: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            controlRow(title: "Content", values: MemoryAlbumTextBlockType.allCases, selected: textBlockType) { type in
                textBlockType = type
            }

            controlRow(title: "Horizontal", values: MemoryAlbumTextHorizontalAlignment.allCases, selected: textHorizontalAlignment) { alignment in
                textHorizontalAlignment = alignment
            }

            controlRow(title: "Vertical", values: MemoryAlbumTextVerticalAlignment.allCases, selected: textVerticalAlignment) { alignment in
                textVerticalAlignment = alignment
            }

            if textBlockType == .titleAndDescription {
                HStack(spacing: MindMorySpacing.sm) {
                    FilterChip(title: "Title first", systemImage: nil, isSelected: textIsTitleFirst) {
                        textIsTitleFirst = true
                    }
                    FilterChip(title: "Description first", systemImage: nil, isSelected: !textIsTitleFirst) {
                        textIsTitleFirst = false
                    }
                }
            }

            if textBlockType != .descriptionOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Title")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    TextField("Enter title", text: $textTitle)
                        .focused($isTitleFocused)
                        .font(MindMoryTypography.bodyMedium)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.Surface.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .stroke(MindMoryColors.Border.subtle)
                        )
                }
            }

            if textBlockType != .titleOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Description")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    TextField("Enter description", text: $textDescription, axis: .vertical)
                        .lineLimit(2...4)
                        .font(MindMoryTypography.bodyMedium)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.Surface.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .stroke(MindMoryColors.Border.subtle)
                        )
                }
            }
        }
    }

    private var typographyControls: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Text("Typography")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.primary)

            if textBlockType != .descriptionOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Title size: \(Int(titleSize))")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    Slider(value: $titleSize, in: 18...44, step: 1)

                    controlRow(title: "Title weight", values: MemoryAlbumTextWeight.allCases, selected: titleWeight) { selectedWeight in
                        titleWeight = selectedWeight
                    }
                }
            }

            if textBlockType != .titleOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Description size: \(Int(descriptionSize))")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)

                    Slider(value: $descriptionSize, in: 12...28, step: 1)

                    controlRow(title: "Description weight", values: MemoryAlbumTextWeight.allCases, selected: descriptionWeight) { selectedWeight in
                        descriptionWeight = selectedWeight
                    }
                }
            }
        }
    }

    private var configuredTextSection: MemoryAlbumTextSection {
        return MemoryAlbumTextSection(
            templateVariant: 0,
            blockType: textBlockType,
            horizontalAlignment: textHorizontalAlignment,
            verticalAlignment: textVerticalAlignment,
            isTitleFirst: textIsTitleFirst,
            title: textTitle,
            description: textDescription,
            style: MemoryAlbumTextStyle(
                titleSize: titleSize,
                descriptionSize: descriptionSize,
                titleWeight: titleWeight,
                descriptionWeight: descriptionWeight
            )
        )
    }

    private var navigationTitle: String {
        if let _ = existingSection {
            return selectedSectionType == .image ? "Edit Image Section" : "Edit Text Section"
        }

        return selectedSectionType == .image ? "Add Image Section" : "Add Text Section"
    }

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            if selectedSectionType == .image {
                Text("Choose an image layout")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text("Pick a layout and tap a preview to add an image section to your album.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            } else {
                Text("Add a text section")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Text("Customize the title, description, and typography for this text block.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)
            }
        }
    }

    private func controlRow<T: CaseIterable & Identifiable & Equatable & Hashable>(
        title: String,
        values: T.AllCases,
        selected: T,
        onSelect: @escaping (T) -> Void
    ) -> some View where T: MemoryAlbumLabelable {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(title)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(Array(values), id: \.self) { value in
                        FilterChip(
                            title: value.label,
                            systemImage: nil,
                            isSelected: selected == value
                        ) {
                            onSelect(value)
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Choose a section layout")
                .font(MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Content.primary)

            Text("Select image or text section. Text sections are fully customizable through content, alignment, and typography controls.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
        }
    }

    // divider labels moved into the bottom card info for clarity

    private var layoutChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                ForEach(1...5, id: \.self) { count in
                    FilterChip(
                        title: "\(count)",
                        systemImage: nil,
                        isSelected: selectedLayoutCount == count
                    ) {
                        selectedLayoutCount = count
                    }
                }
            }
            .padding(.vertical, MindMorySpacing.xs)
        }
    }

    private var layoutOptions: some View {
        VStack(spacing: MindMorySpacing.lg) {
            let displayVariants = layoutVariants.filter { variant in
                // Only show primary variants or non-mirrored layouts
                guard let mirror = variant.mirrorGroup else { return true }
                return variant.variant == mirror.primaryVariant
            }
            
            ForEach(Array(displayVariants.enumerated()), id: \.element.id) { _, variant in
                // subtle divider between options
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(MindMoryColors.Border.subtle)
                    .opacity(0.25)
                    .frame(maxWidth: .infinity)

                let finalVariant = selectedMirrorVariants[variant.variant] ?? variant.variant
                let previewTemplate = MemoryAlbumSectionLayoutCatalog.template(layoutCount: variant.layoutCount, variant: finalVariant)

                VStack(spacing: MindMorySpacing.md) {
                    OptionInfoBar(template: previewTemplate)

                    // Label and mirror tabs at top
                    OptionHeaderBar(
                        template: previewTemplate,
                        selectedMirror: Binding(
                            get: { selectedMirrorVariants[variant.variant] ?? variant.variant },
                            set: { selectedMirrorVariants[variant.variant] = $0 }
                        )
                    )

                    // Image preview
                    Button {
                        saveLayoutTemplate(variant: finalVariant)
                    } label: {
                        MemoryAlbumSectionLayoutOptionView(template: previewTemplate)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var layoutVariants: [MemoryAlbumSectionLayoutTemplate] {
        MemoryAlbumSectionLayoutCatalog.templates(for: selectedLayoutCount)
    }

    private func saveLayoutTemplate(variant: Int) {
        let section = MemoryAlbumSection(
            id: existingSection?.id ?? UUID(),
            layoutCount: selectedLayoutCount,
            layoutVariant: variant,
            photos: Array(repeating: nil, count: selectedLayoutCount)
        )
        onSave(section)
    }
}

    private struct MemoryAlbumSectionLayoutOptionView: View {
    let template: MemoryAlbumSectionLayoutTemplate

    var body: some View {
        GeometryReader { proxy in
            let containerWidth = proxy.size.width

            MemoryAlbumSectionLayoutRenderer(template: template, content: { _ in
                MemoryAlbumSectionTemplatePlaceholder()
            }, availableWidth: containerWidth)
            .frame(width: containerWidth, height: template.estimatedHeight(forWidth: containerWidth))
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            // keep the preview clean: no per-cell debug badges or stacked icon chips
            .frame(maxWidth: .infinity, alignment: .center)
            .clipped()
        }
        .frame(height: template.estimatedHeight(forWidth: {
            // Prefer a UIScreen instance from the active window scene on newer OSes.
            if #available(iOS 26.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return scene.screen.bounds.width - (MindMorySpacing.xl * 2)
                }
                return 390 - (MindMorySpacing.xl * 2)
            } else {
                return UIScreen.main.bounds.width - (MindMorySpacing.xl * 2)
            }
        }()))
    }
}

private struct OptionHeaderBar: View {
    let template: MemoryAlbumSectionLayoutTemplate
    @Binding var selectedMirror: Int

    private var portraitCount: Int { template.frameShapes.filter { $0 == .portrait }.count }
    private var landscapeCount: Int { template.frameShapes.filter { $0 == .landscape }.count }
    private var squareCount: Int { template.frameShapes.filter { $0 == .square }.count }
    private var flexibleCount: Int { template.frameShapes.filter { $0 == .flexible }.count }
    private var columnCount: Int { template.gridColumns.count }
    
    private var mirrorVariant: MemoryAlbumSectionLayoutTemplate? {
        guard let mirror = template.mirrorGroup, mirror.mirrorVariant != template.variant else { return nil }
        return MemoryAlbumSectionLayoutCatalog.template(layoutCount: template.layoutCount, variant: mirror.mirrorVariant)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            // Mirror tabs if applicable
            if let mirror = template.mirrorGroup {
                HStack(spacing: MindMorySpacing.sm) {
                    mirrorTabButton(
                        isSelected: selectedMirror == template.variant,
                        title: mirror.mirrorType == .vertical ? "Left" : "Top",
                        icon: mirror.mirrorType == .vertical ? "arrow.left.and.right" : "arrow.up.and.down"
                    ) {
                        selectedMirror = template.variant
                    }

                    mirrorTabButton(
                        isSelected: selectedMirror == mirror.mirrorVariant,
                        title: mirror.mirrorType == .vertical ? "Right" : "Bottom",
                        icon: mirror.mirrorType == .vertical ? "arrow.right.and.left" : "arrow.down.and.up"
                    ) {
                        selectedMirror = mirror.mirrorVariant
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func mirrorTabButton(isSelected: Bool, title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(MindMoryTypography.labelSmall)
                Text(title)
                    .font(MindMoryTypography.labelSmall)
            }
            .frame(maxWidth: .infinity)
            .padding(10)
                .background(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Surface.surface)
                .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.primary)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .stroke(MindMoryColors.Border.subtle, lineWidth: isSelected ? 0 : 1)
                )
        }
    }

    @ViewBuilder
    private func capsulePill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(color)

            Text(text)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(color)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
    }
}

private struct OptionInfoBar: View {
    let template: MemoryAlbumSectionLayoutTemplate

    private var portraitCount: Int { template.frameShapes.filter { $0 == .portrait }.count }
    private var landscapeCount: Int { template.frameShapes.filter { $0 == .landscape }.count }
    private var squareCount: Int { template.frameShapes.filter { $0 == .square }.count }
    private var flexibleCount: Int { template.frameShapes.filter { $0 == .flexible }.count }
    private var columnCount: Int { template.gridColumns.count }

    private var layoutDescriptor: String {
        if template.layoutCount == 1 {
            return template.frameShapes.first?.label ?? "Single"
        }

        if columnCount == 1 {
            return "Vertical"
        }

        if template.layoutCount == columnCount && template.variant == 0 {
            return "Horizontal"
        }

        return "Mixed"
    }

    private var firstColumnShapes: [MemoryAlbumFrameShape] {
        switch template.layoutCount {
        case 1:
            return [template.frameShapes[0]]
        case 2:
            switch template.variant {
            case 1:
                return template.frameShapes
            default:
                return [template.frameShapes[0]]
            }
        case 3:
            switch template.variant {
            case 1:
                return [template.frameShapes[0], template.frameShapes[1]]
            case 2:
                return [template.frameShapes[0], template.frameShapes[2]]
            case 3:
                return [template.frameShapes[0], template.frameShapes[1]]
            default:
                return [template.frameShapes[0]]
            }
        case 4:
            switch template.variant {
            case 0:
                return [template.frameShapes[0], template.frameShapes[2]]
            case 1:
                return [template.frameShapes[0]]
            case 2:
                return [template.frameShapes[0], template.frameShapes[1]]
            case 3:
                return [template.frameShapes[0], template.frameShapes[1]]
            case 4:
                return [template.frameShapes[0], template.frameShapes[1]]
            default:
                return [template.frameShapes[0]]
            }
        case 5:
            switch template.variant {
            case 0:
                return [template.frameShapes[0], template.frameShapes[3]]
            case 1:
                return [template.frameShapes[0], template.frameShapes[1]]
            case 2:
                return [template.frameShapes[0]]
            case 3:
                return [template.frameShapes[0], template.frameShapes[2]]
            default:
                return [template.frameShapes[0], template.frameShapes[1]]
            }
        default:
            return [template.frameShapes[0]]
        }
    }

    private var firstColumnText: String? {
        let count = firstColumnShapes.count
        guard count > 0 else { return nil }

        let shapeLabels = firstColumnShapes.map { $0.label.lowercased() }.joined(separator: " · ")
        return "First column: \(count) image\(count == 1 ? "" : "s") — \(shapeLabels)"
    }

    private var descriptorColor: Color {
        switch layoutDescriptor {
        case "Vertical":
            return MindMoryColors.Content.secondary
        case "Horizontal":
            return MindMoryColors.Content.link
        default:
            return MindMoryColors.Content.tertiary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            HStack(alignment: .top, spacing: MindMorySpacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.title)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Content.link)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)

                    Text(layoutDescriptor.uppercased())
                        .font(MindMoryTypography.labelSmall)
                        .foregroundStyle(descriptorColor)
                }

                Spacer()

                Badge(iconName: "photo.on.rectangle", text: "\(template.layoutCount) images", tint: MindMoryColors.Content.tertiary, style: .iconText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    if columnCount > 1 {
                        Badge(iconName: "square.grid.2x2", text: "\(columnCount) cols", tint: MindMoryColors.Content.link, style: .iconText)
                    }

                    if portraitCount > 0 { Badge(iconName: MemoryAlbumFrameShape.portrait.iconName, text: "\(portraitCount)", tint: MindMoryColors.Content.link, style: .iconText) }
                    if landscapeCount > 0 { Badge(iconName: MemoryAlbumFrameShape.landscape.iconName, text: "\(landscapeCount)", tint: MindMoryColors.Content.tertiary, style: .iconText) }
                    if squareCount > 0 { Badge(iconName: MemoryAlbumFrameShape.square.iconName, text: "\(squareCount)", tint: MindMoryColors.Content.secondary, style: .iconText) }
                    if flexibleCount > 0 { Badge(iconName: MemoryAlbumFrameShape.flexible.iconName, text: "\(flexibleCount)", tint: MindMoryColors.Content.secondary, style: .iconText) }
                }
                .padding(.vertical, MindMorySpacing.xs)
            }

            if let firstColumnText {
                Text(firstColumnText)
                    .font(MindMoryTypography.labelSmall)
                    .foregroundStyle(MindMoryColors.Content.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Surface.primary.opacity(0.18))
        )
    }

    @ViewBuilder
    private func badgePill(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(tint)

            Text(text)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(tint)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(tint.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
    }

    @ViewBuilder
    private func capsulePill(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(color)

            Text(text)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(color)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(color.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
    }
}

private struct MemoryAlbumSectionTemplatePlaceholder: View {
    var body: some View {
        ImagePlaceholder(
            image: nil,
            imageName: nil,
            subtitle: "Layout preview",
            cornerRadius: nil
        )
        // Note: do not apply inner corner clipping here so adjacent cells render seamlessly
    }
}



extension MemoryAlbumTextBlockType: MemoryAlbumLabelable {}
extension MemoryAlbumTextHorizontalAlignment: MemoryAlbumLabelable {}
extension MemoryAlbumTextVerticalAlignment: MemoryAlbumLabelable {}
extension MemoryAlbumTextWeight: MemoryAlbumLabelable {}

#Preview {
    NavigationStack {
        MemoryAlbumSectionCreateView { _ in }
    }
}
