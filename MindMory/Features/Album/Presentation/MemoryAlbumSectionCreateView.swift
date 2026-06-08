import SwiftUI

protocol MemoryAlbumLabelable {
    var label: String { get }
}

struct MemoryAlbumSectionCreateView: View {
    @State private var selectedSectionType: MemoryAlbumSectionType = .image
    @State private var selectedLayoutCount: Int = 1
    @State private var textBlockType: MemoryAlbumTextBlockType = .titleAndDescription
    @State private var textHorizontalAlignment: MemoryAlbumTextHorizontalAlignment = .leading
    @State private var textVerticalAlignment: MemoryAlbumTextVerticalAlignment = .top
    @State private var textIsTitleFirst: Bool = true
    @State private var textTitle: String = "A memory headline"
    @State private var textDescription: String = "Describe this memory section with context and feelings."
    @State private var isAdaptiveText: Bool = false
    @State private var adaptiveTextOffset: CGSize = .zero
    @State private var shapeOffset: CGSize = .zero
    @State private var titleSize: Double = MemoryAlbumTextStyle.default.titleSize
    @State private var descriptionSize: Double = MemoryAlbumTextStyle.default.descriptionSize
    @State private var titleWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.titleWeight
    @State private var descriptionWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.descriptionWeight
    @State private var selectedShapeType: MemoryAlbumShapeType = .rectangle
    @State private var selectedShapeFillHex: String = "3B82F6"
    @State private var selectedShapeBorderHex: String = "F8FAFC"
    @State private var selectedShapeOpacity: Double = 1.0
    @State private var selectedShapeBorderWidth: Double = 2.0
    @State private var selectedShapeBlendMode: MemoryAlbumShapeBlendMode = .normal
    @State private var selectedShapeScale: Double = 1.0

    let existingSection: MemoryAlbumSection?
    let onSave: (MemoryAlbumSection) -> Void

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
                _isAdaptiveText = State(initialValue: textSection.isAdaptive)
                _adaptiveTextOffset = State(initialValue: textSection.offset)
                _titleSize = State(initialValue: textSection.style.titleSize)
                _descriptionSize = State(initialValue: textSection.style.descriptionSize)
                _titleWeight = State(initialValue: textSection.style.titleWeight)
                _descriptionWeight = State(initialValue: textSection.style.descriptionWeight)
            }

            if let shapeSection = section.shapeSection {
                _selectedShapeType = State(initialValue: shapeSection.type)
                _selectedShapeFillHex = State(initialValue: shapeSection.style.fillHex)
                _selectedShapeBorderHex = State(initialValue: shapeSection.style.borderHex)
                _selectedShapeOpacity = State(initialValue: shapeSection.style.opacity)
                _selectedShapeBorderWidth = State(initialValue: shapeSection.style.borderWidth)
                _selectedShapeBlendMode = State(initialValue: shapeSection.style.blendMode)
                _shapeOffset = State(initialValue: shapeSection.offset)
                _selectedShapeScale = State(initialValue: shapeSection.scale)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header

                sectionTypeChips

                if selectedSectionType == .image {
                    imageSectionBuilder
                } else if selectedSectionType == .shape {
                    shapeSectionBuilder
                } else {
                    textSectionBuilder
                }

                Spacer(minLength: MindMorySpacing.xl)
            }
            .padding(MindMorySpacing.xl)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Add Section")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var imageSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            layoutChips

            Text("Pick a layout for your image section. You’ll choose the photos after returning to the album page.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            layoutOptions
        }
    }

    private var shapeSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            Text("Customize shape section")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(MemoryAlbumShapeType.allCases) { type in
                        FilterChip(title: type.label, isSelected: selectedShapeType == type) {
                            selectedShapeType = type
                        }
                    }
                }
                .padding(.vertical, MindMorySpacing.xs)
            }

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Fill color")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)

                shapeColorOptions
            }

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Border color")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)

                shapeBorderColorOptions
            }

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Style")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)

                HStack(spacing: MindMorySpacing.sm) {
                    Text("Opacity")
                    Slider(value: $selectedShapeOpacity, in: 0.3...1.0)
                }
                HStack(spacing: MindMorySpacing.sm) {
                    Text("Border")
                    Slider(value: $selectedShapeBorderWidth, in: 0...8, step: 1)
                }
                HStack(spacing: MindMorySpacing.sm) {
                    Text("Size")
                    Slider(value: $selectedShapeScale, in: 0.6...1.8)
                }
                controlRow(title: "Filter", values: MemoryAlbumShapeBlendMode.allCases, selected: selectedShapeBlendMode) { mode in
                    selectedShapeBlendMode = mode
                }
            }

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Preview")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textPrimary)

                shapePreview
                    .frame(height: 220)
            }

            PrimaryButton(title: existingSection == nil ? "Add Shape Section" : "Save Section") {
                onSave(
                    MemoryAlbumSection(
                        id: existingSection?.id ?? UUID(),
                        content: .shape(configuredShapeSection)
                    )
                )
            }
        }
    }

    private var textSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            Text("Customize text section")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textPrimary)

            adaptiveTextToggle

            if isAdaptiveText {
                adaptiveTextInput
            } else {
                textTypeControls
                typographyControls
            }

            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Preview")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textPrimary)

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

    private var adaptiveTextInput: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Text")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            TextField("Enter text", text: $textTitle)
                .font(MindMoryTypography.bodyMedium)
                .padding(MindMorySpacing.sm)
                .background(MindMoryColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .stroke(MindMoryColors.border)
                )
        }
    }

    private var adaptiveTextToggle: some View {
        HStack(spacing: MindMorySpacing.sm) {
            FilterChip(title: "Standard", isSelected: !isAdaptiveText) {
                isAdaptiveText = false
            }
            FilterChip(title: "Adaptive", isSelected: isAdaptiveText) {
                isAdaptiveText = true
            }
        }
    }

    private var sectionTypeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                FilterChip(title: "Image", isSelected: selectedSectionType == .image) {
                    selectedSectionType = .image
                }

                FilterChip(title: "Text", isSelected: selectedSectionType == .text) {
                    selectedSectionType = .text
                }

                FilterChip(title: "Shape", isSelected: selectedSectionType == .shape) {
                    selectedSectionType = .shape
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
                    FilterChip(title: "Title first", isSelected: textIsTitleFirst) {
                        textIsTitleFirst = true
                    }

                    FilterChip(title: "Description first", isSelected: !textIsTitleFirst) {
                        textIsTitleFirst = false
                    }
                }
            }

            if textBlockType != .descriptionOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Title")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    TextField("Enter title", text: $textTitle)
                        .font(MindMoryTypography.bodyMedium)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                }
            }

            if textBlockType != .titleOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Description")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    TextField("Enter description", text: $textDescription, axis: .vertical)
                        .lineLimit(2...4)
                        .font(MindMoryTypography.bodyMedium)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                }
            }
        }
    }

    private var typographyControls: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.md) {
            Text("Typography")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textPrimary)

            if textBlockType != .descriptionOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Title size: \(Int(titleSize))")
                        .font(MindMoryTypography.caption)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    Slider(value: $titleSize, in: 18...44, step: 1)

                    controlRow(title: "Title weight", values: MemoryAlbumTextWeight.allCases, selected: titleWeight) { selectedWeight in
                        titleWeight = selectedWeight
                    }
                }
            }

            if textBlockType != .titleOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Description size: \(Int(descriptionSize))")
                        .font(MindMoryTypography.caption)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    Slider(value: $descriptionSize, in: 12...28, step: 1)

                    controlRow(title: "Description weight", values: MemoryAlbumTextWeight.allCases, selected: descriptionWeight) { selectedWeight in
                        descriptionWeight = selectedWeight
                    }
                }
            }
        }
    }

    private var configuredTextSection: MemoryAlbumTextSection {
        if isAdaptiveText {
            return MemoryAlbumTextSection(
                templateVariant: 0,
                blockType: .titleOnly,
                horizontalAlignment: .center,
                verticalAlignment: .center,
                isTitleFirst: true,
                title: textTitle,
                description: "",
                style: .default,
                isAdaptive: true,
                offset: adaptiveTextOffset,
                scale: 1
            )
        }

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
            ),
            isAdaptive: isAdaptiveText
        )
    }

    private var configuredShapeSection: MemoryAlbumShapeSection {
        MemoryAlbumShapeSection(
            type: selectedShapeType,
            style: MemoryAlbumShapeStyle(
                fillHex: selectedShapeFillHex,
                borderHex: selectedShapeBorderHex,
                borderWidth: selectedShapeBorderWidth,
                opacity: selectedShapeOpacity,
                blendMode: selectedShapeBlendMode
            ),
            offset: shapeOffset,
            scale: CGFloat(selectedShapeScale)
        )
    }

    private var shapeColorOptions: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ForEach(["3B82F6", "10B981", "F59E0B", "EF4444", "8B5CF6", "14B8A6"], id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(selectedShapeFillHex == hex ? MindMoryColors.primaryGreen : Color.clear, lineWidth: 3)
                    )
                    .onTapGesture {
                        selectedShapeFillHex = hex
                    }
            }
        }
    }

    private var shapeBorderColorOptions: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ForEach(["FFFFFF", "F8FAFC", "475569", "0F172A", "F97316"], id: \.self) { hex in
                Circle()
                    .fill(Color(hex: hex))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(selectedShapeBorderHex == hex ? MindMoryColors.primaryGreen : Color.clear, lineWidth: 3)
                    )
                    .onTapGesture {
                        selectedShapeBorderHex = hex
                    }
            }
        }
    }

    private var shapePreview: some View {
        let style = configuredShapeSection.style
        let blend = blendMode(for: style.blendMode)

        return ZStack {
            shapeFillView(for: selectedShapeType, fillColor: style.fillColor.opacity(style.opacity), blend: blend)
            shapeStrokeView(for: selectedShapeType, borderColor: style.borderColor, lineWidth: selectedShapeBorderWidth)
        }
    }

    @ViewBuilder
    private func shapeFillView(for type: MemoryAlbumShapeType, fillColor: Color, blend: BlendMode) -> some View {
        switch type {
        case .rectangle:
            Rectangle()
                .fill(fillColor)
                .blendMode(blend)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(fillColor)
                .blendMode(blend)
        case .circle:
            Circle()
                .fill(fillColor)
                .blendMode(blend)
        case .capsule:
            Capsule()
                .fill(fillColor)
                .blendMode(blend)
        case .diamond:
            DiamondShape()
                .fill(fillColor)
                .blendMode(blend)
        }
    }

    @ViewBuilder
    private func shapeStrokeView(for type: MemoryAlbumShapeType, borderColor: Color, lineWidth: Double) -> some View {
        switch type {
        case .rectangle:
            Rectangle()
                .stroke(borderColor, lineWidth: lineWidth)
        case .roundedRectangle:
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(borderColor, lineWidth: lineWidth)
        case .circle:
            Circle()
                .stroke(borderColor, lineWidth: lineWidth)
        case .capsule:
            Capsule()
                .stroke(borderColor, lineWidth: lineWidth)
        case .diamond:
            DiamondShape()
                .stroke(borderColor, lineWidth: lineWidth)
        }
    }

    private struct DiamondShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.closeSubpath()
            return path
        }
    }

    private func blendMode(for mode: MemoryAlbumShapeBlendMode) -> BlendMode {
        switch mode {
        case .normal:
            return .normal
        case .multiply:
            return .multiply
        case .overlay:
            return .overlay
        case .screen:
            return .screen
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
                .font(MindMoryTypography.caption)
                .foregroundStyle(MindMoryColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MindMorySpacing.sm) {
                    ForEach(Array(values), id: \.self) { value in
                        FilterChip(
                            title: value.label,
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
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)

            Text("Select image or text section. Text sections are fully customizable through content, alignment, and typography controls.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)
        }
    }

    private var layoutChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                ForEach(1...5, id: \.self) { count in
                    FilterChip(
                        title: "\(count)",
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
        VStack(spacing: MindMorySpacing.md) {
            ForEach(Array(layoutVariants.enumerated()), id: \.element.id) { index, variant in
                Button {
                    saveLayoutTemplate(variant: variant.variant)
                } label: {
                    MemoryAlbumSectionTemplateCard(template: variant)
                }
                .buttonStyle(.plain)

                if index < layoutVariants.count - 1 {
                    Divider()
                        .background(MindMoryColors.border)
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

extension MemoryAlbumTextBlockType: MemoryAlbumLabelable {}
extension MemoryAlbumTextHorizontalAlignment: MemoryAlbumLabelable {}
extension MemoryAlbumTextVerticalAlignment: MemoryAlbumLabelable {}
extension MemoryAlbumTextWeight: MemoryAlbumLabelable {}
extension MemoryAlbumShapeBlendMode: MemoryAlbumLabelable {}

#Preview {
    NavigationStack {
        MemoryAlbumSectionCreateView { _ in }
    }
}
