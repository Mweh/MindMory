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
    @State private var titleSize: Double = MemoryAlbumTextStyle.default.titleSize
    @State private var descriptionSize: Double = MemoryAlbumTextStyle.default.descriptionSize
    @State private var titleWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.titleWeight
    @State private var descriptionWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.descriptionWeight

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
                _titleSize = State(initialValue: textSection.style.titleSize)
                _descriptionSize = State(initialValue: textSection.style.descriptionSize)
                _titleWeight = State(initialValue: textSection.style.titleWeight)
                _descriptionWeight = State(initialValue: textSection.style.descriptionWeight)
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                header

                sectionTypeChips

                switch selectedSectionType {
                case .image:
                    imageSectionBuilder
                case .base:
                    baseSectionBuilder
                case .text:
                    textSectionBuilder
                }
            }
            .padding(MindMorySpacing.xl)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Add Section")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedSectionType) { _, selectedSectionType in
            if selectedSectionType == .base && selectedLayoutCount < 2 {
                selectedLayoutCount = 2
            }
        }
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

    private var baseSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            layoutChips

            Text("Pick a base layout for a mixed content section. You can add image or text cells after it is created.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            layoutOptions
        }
    }

    private var textSectionBuilder: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            Text("Customize text section")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textPrimary)

            textTypeControls
            typographyControls

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

    private var sectionTypeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: MindMorySpacing.sm) {
                FilterChip(title: "Image", isSelected: selectedSectionType == .image) {
                    selectedSectionType = .image
                }

                FilterChip(title: "Text", isSelected: selectedSectionType == .text) {
                    selectedSectionType = .text
                }

                FilterChip(title: "Base", isSelected: selectedSectionType == .base) {
                    selectedSectionType = .base
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
                ForEach(layoutCountOptions, id: \.self) { count in
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

    private var layoutCountOptions: [Int] {
        switch selectedSectionType {
        case .image:
            return Array(1...5)
        case .base:
            return Array(2...5)
        case .text:
            return []
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
        let section: MemoryAlbumSection

        switch selectedSectionType {
        case .image:
            section = MemoryAlbumSection(
                id: existingSection?.id ?? UUID(),
                layoutCount: selectedLayoutCount,
                layoutVariant: variant,
                photos: Array(repeating: nil, count: selectedLayoutCount)
            )
        case .base:
            section = MemoryAlbumSection(
                id: existingSection?.id ?? UUID(),
                baseLayoutCount: selectedLayoutCount,
                layoutVariant: variant,
                cells: Array(repeating: .placeholder, count: selectedLayoutCount)
            )
        case .text:
            section = MemoryAlbumSection(
                id: existingSection?.id ?? UUID(),
                textSection: configuredTextSection
            )
        }

        onSave(section)
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
