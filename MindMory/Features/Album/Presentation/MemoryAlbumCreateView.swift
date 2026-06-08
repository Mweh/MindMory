import PhotosUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct MemoryAlbumCreateView: View {
    enum Step {
        case details
        case selectPhotos
    }

    @StateObject private var viewModel: MemoryAlbumViewModel
    @State private var selectedCoverPhotoItem: PhotosPickerItem?
    @State private var selectedSectionPhotoItem: PhotosPickerItem?
    @State private var selectedPickerSectionID: UUID?
    @State private var selectedPickerIndex: Int?
    @State private var isAddingSection = false
    @State private var isShowingPreview = false
    @State private var selectedSectionID: UUID?
    @State private var selectedTextTitle: String = ""
    @State private var selectedTextDescription: String = ""
    @State private var isShowingTextEditor = false
    @State private var selectedBaseCellSectionID: UUID?
    @State private var selectedBaseCellIndex: Int?
    @State private var isShowingBaseTextEditor = false
    @State private var selectedBaseTextBlockType: MemoryAlbumTextBlockType = .titleAndDescription
    @State private var selectedBaseTextHorizontalAlignment: MemoryAlbumTextHorizontalAlignment = .leading
    @State private var selectedBaseTextVerticalAlignment: MemoryAlbumTextVerticalAlignment = .top
    @State private var selectedBaseTextIsTitleFirst: Bool = true
    @State private var selectedBaseTitle: String = "A memory headline"
    @State private var selectedBaseDescription: String = "Describe this memory section with context and feelings."
    @State private var selectedBaseTitleSize: Double = MemoryAlbumTextStyle.default.titleSize
    @State private var selectedBaseDescriptionSize: Double = MemoryAlbumTextStyle.default.descriptionSize
    @State private var selectedBaseTitleWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.titleWeight
    @State private var selectedBaseDescriptionWeight: MemoryAlbumTextWeight = MemoryAlbumTextStyle.default.descriptionWeight
    @State private var sectionInsertionIndex: Int?
    @State private var draggingSectionID: UUID?
    @State private var currentStep: Step = .details
    let onCreate: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    init(viewModel: MemoryAlbumViewModel, onCreate: @escaping (Album) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreate = onCreate
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    if currentStep == .details {
                        stepHeader
                    }

                    switch currentStep {
                    case .details:
                        detailsStep
                    case .selectPhotos:
                        selectPhotosStep
                    }

                    if currentStep == .details {
                        footerButtons
                    }
                }
                .padding(MindMorySpacing.xl)
            }
            .onTapGesture {
                draggingSectionID = nil
            }
        }
        .navigationDestination(isPresented: $isAddingSection) {
            MemoryAlbumSectionCreateView { section in
                if let index = sectionInsertionIndex {
                    viewModel.insertSection(section, at: index)
                } else {
                    viewModel.addSection(section)
                }
                sectionInsertionIndex = nil
                isAddingSection = false
            }
        }
        .navigationDestination(isPresented: $isShowingPreview) {
            MemoryAlbumPreviewView(
                viewModel: viewModel,
                onSave: viewModel.saveAlbum,
                onCreate: { album in
                    onCreate(album)
                    dismiss()
                }
            )
        }
        .onChange(of: currentStep) { _, newStep in
            if newStep == .selectPhotos, selectedSectionID == nil {
                selectedSectionID = viewModel.sections.first?.id
            }
        }
        .onChange(of: selectedSectionID) { _, _ in
            syncSelectedTextSection()
        }
        .onChange(of: viewModel.sections) { _, _ in
            if currentStep == .selectPhotos, selectedSectionID == nil {
                selectedSectionID = viewModel.sections.first?.id
            }
            syncSelectedTextSection()
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Create Memory Album")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingTextEditor) {
            sectionTextEditorSheet
        }
        .sheet(isPresented: $isShowingBaseTextEditor) {
            baseCellTextEditorSheet
        }
        .onChange(of: selectedCoverPhotoItem) { _, newItem in
            Task {
                guard let item = newItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.updateCoverPhoto(from: [data])
                }
            }
        }
        .onChange(of: selectedSectionPhotoItem) { _, newItem in
            guard let item = newItem else { return }
            guard
                let sectionId = selectedPickerSectionID,
                let index = selectedPickerIndex
            else {
                selectedSectionPhotoItem = nil
                return
            }

            // Clear picker item immediately to avoid duplicate callback loops.
            selectedSectionPhotoItem = nil

            Task {
                guard let data = try? await item.loadTransferable(type: Data.self) else {
                    await MainActor.run {
                        selectedPickerSectionID = nil
                        selectedPickerIndex = nil
                    }
                    return
                }

                let normalizedData: Data
                if let image = UIImage(data: data), let compressedData = image.jpegData(compressionQuality: 0.82) {
                    normalizedData = compressedData
                } else {
                    normalizedData = data
                }

                let photo = AlbumPhoto(id: UUID(), imageData: normalizedData)

                await MainActor.run {
                    viewModel.updateSectionPhoto(sectionId: sectionId, index: index, photo: photo)
                    selectedPickerSectionID = nil
                    selectedPickerIndex = nil
                }
            }
        }
        .alert("Memory Album", isPresented: alertBinding) {
            Button("OK", role: .cancel) {
                handleAlertDismiss()
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissAlert()
                }
            }
        )
    }

    private func handleAlertDismiss() {
        guard let album = viewModel.savedAlbum else {
            viewModel.dismissAlert()
            return
        }

        viewModel.dismissAlert()
        onCreate(album)
        dismiss()
    }

    private var footerButtons: some View {
        HStack(spacing: MindMorySpacing.sm) {
            if currentStep == .selectPhotos {
                Button("Back") {
                    currentStep = .details
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button(currentStep == .details ? "Continue" : "Preview") {
                if currentStep == .details {
                    currentStep = .selectPhotos
                    selectedSectionID = selectedSectionID ?? viewModel.sections.first?.id
                } else {
                    isShowingPreview = true
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(currentStep == .details && viewModel.albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case .details:
            return "Album details"
        case .selectPhotos:
            return "Add sections"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case .details:
            return "Choose an album title and cover photo."
        case .selectPhotos:
            return "Add sections, then pick photos or text content."
        }
    }

    private func syncSelectedTextSection() {
        guard let sectionId = selectedSectionID,
              let section = viewModel.sections.first(where: { $0.id == sectionId }),
              case .text(let textSection) = section.content
        else {
            return
        }

        selectedTextTitle = textSection.title
        selectedTextDescription = textSection.description
    }

    private var sectionTextEditorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    Text("Edit text section")
                        .font(MindMoryTypography.headingLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Title")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        TextField("Enter title", text: $selectedTextTitle)
                            .font(MindMoryTypography.bodyMedium)
                            .padding(MindMorySpacing.sm)
                            .background(MindMoryColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                    .stroke(MindMoryColors.border)
                            )
                    }

                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Description")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        TextField("Enter description", text: $selectedTextDescription, axis: .vertical)
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
                .padding(MindMorySpacing.xl)
            }
            .navigationTitle("Edit text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateSelectedTextSection()
                    }
                    .disabled(selectedTextTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingTextEditor = false
                    }
                }
            }
        }
    }

    private func updateSelectedTextSection() {
        guard let sectionId = selectedSectionID,
              let section = viewModel.sections.first(where: { $0.id == sectionId }),
              case .text(let currentTextSection) = section.content
        else {
            return
        }

        let updatedTextSection = MemoryAlbumTextSection(
            templateVariant: currentTextSection.templateVariant,
            blockType: currentTextSection.blockType,
            horizontalAlignment: currentTextSection.horizontalAlignment,
            verticalAlignment: currentTextSection.verticalAlignment,
            isTitleFirst: currentTextSection.isTitleFirst,
            title: selectedTextTitle,
            description: selectedTextDescription,
            style: currentTextSection.style
        )

        viewModel.updateSection(
            MemoryAlbumSection(id: sectionId, textSection: updatedTextSection)
        )

        isShowingTextEditor = false
    }

    private func previewImageCell(at index: Int, in section: MemoryAlbumSection) -> some View {
        let shape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        return ZStack {
            Color.clear

            if let image = imageForSectionCell(index: index, section: section) {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            } else {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(shape)
        .overlay(shape.stroke(MindMoryColors.border))
    }

    private func overlappedImageSection(_ section: MemoryAlbumSection, template: MemoryAlbumSectionLayoutTemplate, isPreview: Bool) -> some View {
        return GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let cardWidth = size * 0.72
            ZStack {
                ForEach(0..<template.layoutCount, id: \.self) { index in
                    Group {
                        if isPreview {
                            previewImageCell(at: index, in: section)
                        } else {
                            sectionImageCell(at: index, in: section)
                        }
                    }
                    .frame(width: cardWidth, height: cardWidth * 1.2)
                    .rotationEffect(overlayRotations(for: template.layoutCount)[index])
                    .offset(x: CGFloat(index - template.layoutCount / 2) * 14, y: CGFloat(index - template.layoutCount / 2) * 6)
                    .zIndex(Double(index))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
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

    private var stepHeader: some View {
        HStack(spacing: MindMorySpacing.sm) {
            Text(stepTitle)
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)

            Spacer()

            Text(stepSubtitle)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)
                .multilineTextAlignment(.trailing)
        }
    }
    

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Memory title")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    TextField("Enter memory title", text: $viewModel.albumName)
                        .font(MindMoryTypography.bodyMedium)
                        .padding(MindMorySpacing.md)
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Cover photo")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    PhotosPicker(
                        selection: $selectedCoverPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.fill.on.rectangle.fill")
                            Text(viewModel.coverPhoto.map { _ in "Change cover photo" } ?? "Choose cover photo")
                        }
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)
                        .padding(MindMorySpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                    }

                    if let coverPhoto = viewModel.coverPhoto, let image = coverPhoto.uiImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(MindMoryRadius.large)
                    }
                }
            }

        }
    }

    private var selectPhotosStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            ForEach(viewModel.sections) { section in
                draggableSection(section)
            }
            .animation(
                .interactiveSpring(response: 0.4, dampingFraction: 0.82, blendDuration: 0.25),
                value: viewModel.sections
            )

            PrimaryButton(title: "Add Section") {
                sectionInsertionIndex = nil
                isAddingSection = true
            }
            .disabled(currentStep != .selectPhotos)
        }
        .toolbar {
            if currentStep == .selectPhotos {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Preview") {
                        isShowingPreview = true
                    }
                }
            }
        }
    }

    private func draggableSection(_ section: MemoryAlbumSection) -> some View {
        let isSelected = selectedSectionID == section.id
        let isDimmed = selectedSectionID != nil && !isSelected

        return sectionCard(section)
            .opacity(isDimmed ? 0.86 : 1)
            .zIndex(isSelected ? 1 : 0)
            .overlay(alignment: .topTrailing) {
                Menu {
                    Button("Add section above") {
                        guard let index = viewModel.sections.firstIndex(where: { $0.id == section.id }) else { return }
                        sectionInsertionIndex = index
                        isAddingSection = true
                    }
                    Button("Add section below") {
                        guard let index = viewModel.sections.firstIndex(where: { $0.id == section.id }) else { return }
                        sectionInsertionIndex = index + 1
                        isAddingSection = true
                    }
                    Button("Drag") {
                        draggingSectionID = section.id
                        selectedSectionID = section.id
                    }
                    Button("Delete section", role: .destructive) {
                        viewModel.removeSection(id: section.id)
                        if selectedSectionID == section.id {
                            selectedSectionID = viewModel.sections.first?.id
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(MindMoryColors.textSecondary)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    selectedSectionID = section.id
                }
                .padding(MindMorySpacing.xs)
            }
            .overlay(
                Group {
                    if draggingSectionID == section.id {
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .stroke(MindMoryColors.primaryGreen.opacity(0.6), style: StrokeStyle(lineWidth: 3, dash: [6]))
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
            .onTapGesture {
                draggingSectionID = nil
                selectedSectionID = section.id
                if case .text = section.content {
                    syncSelectedTextSection()
                    isShowingTextEditor = true
                }
            }
            .draggable(section.id.uuidString)
            .dropDestination(for: String.self) { droppedItems, _ in
                guard
                    let rawValue = droppedItems.first,
                    let sourceId = UUID(uuidString: rawValue)
                else {
                    draggingSectionID = nil
                    return false
                }

                viewModel.moveSection(sourceId: sourceId, destinationId: section.id)
                draggingSectionID = nil
                return true
            }
    }

    @ViewBuilder
    private func sectionCard(_ section: MemoryAlbumSection) -> some View {
        switch section.content {
        case .image(let layoutCount, let layoutVariant, _):
            let template = MemoryAlbumSectionLayoutCatalog.template(
                layoutCount: layoutCount,
                variant: layoutVariant
            )

            if template.isOverlayStyle {
                overlappedImageSection(section, template: template, isPreview: false)
                    .frame(height: template.albumHeight)
            } else {
                MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                    sectionImageCell(at: photoIndex, in: section)
                }
                .frame(height: template.albumHeight)
            }
        case .text(let textSection):
            MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: true)
        case .base(let layoutCount, let layoutVariant, _):
            let template = MemoryAlbumSectionLayoutCatalog.template(
                layoutCount: layoutCount,
                variant: layoutVariant
            )

            MemoryAlbumSectionLayoutRenderer(template: template) { cellIndex in
                baseSectionCell(at: cellIndex, in: section, isPreview: false)
            }
            .frame(height: template.albumHeight)
        }
    }


    @ViewBuilder
    private func sectionImageCell(at index: Int, in section: MemoryAlbumSection) -> some View {
        PhotosPicker(
            selection: bindingForSectionPhoto(sectionId: section.id, index: index),
            matching: .images,
            photoLibrary: .shared()
        ) {
            let shape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

            ZStack {
                Color.clear

                if let image = imageForSectionCell(index: index, section: section) {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(shape)
            .overlay(shape.stroke(MindMoryColors.border))
            .contentShape(shape)
        }
        .buttonStyle(.plain)
    }

    private func bindingForSectionPhoto(sectionId: UUID, index: Int) -> Binding<PhotosPickerItem?> {
        Binding(
            get: { selectedSectionPhotoItem },
            set: { newValue in
                selectedPickerSectionID = sectionId
                selectedPickerIndex = index
                selectedSectionPhotoItem = newValue
            }
        )
    }

    private func imageForSectionCell(index: Int, section: MemoryAlbumSection) -> UIImage? {
        switch section.content {
        case .image(_, _, let photos):
            guard photos.indices.contains(index) else { return nil }
            guard let photo = photos[index] else { return nil }
            return photo.uiImage
        case .base(_, _, let cells):
            guard cells.indices.contains(index) else { return nil }
            guard case .image(let photo) = cells[index] else { return nil }
            return photo.uiImage
        default:
            return nil
        }
    }

    @ViewBuilder
    private func baseSectionCell(at index: Int, in section: MemoryAlbumSection, isPreview: Bool) -> some View {
        if case .base(_, _, let cells) = section.content {
            let cell = cells.indices.contains(index) ? cells[index] : .placeholder

            switch cell {
            case .placeholder:
                basePlaceholderCell(sectionId: section.id, index: index)
            case .image:
                if isPreview {
                    previewImageCell(at: index, in: section)
                } else {
                    sectionImageCell(at: index, in: section)
                }
            case .text(let textSection):
                if isPreview {
                    MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: true)
                } else {
                    Button {
                        openBaseTextEditor(sectionId: section.id, index: index, existingText: textSection)
                    } label: {
                        MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: false)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(MindMoryColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                    .stroke(MindMoryColors.border)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func basePlaceholderCell(sectionId: UUID, index: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        VStack(spacing: MindMorySpacing.sm) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text("Add content")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            HStack(spacing: MindMorySpacing.sm) {
                PhotosPicker(
                    selection: bindingForSectionPhoto(sectionId: sectionId, index: index),
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Image(systemName: "photo")
                        .font(.title3)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                        .padding(EdgeInsets(top: MindMorySpacing.xs, leading: MindMorySpacing.sm, bottom: MindMorySpacing.xs, trailing: MindMorySpacing.sm))
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    openBaseTextEditor(sectionId: sectionId, index: index, existingText: nil)
                } label: {
                    Image(systemName: "text.quote")
                        .font(.title3)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                        .padding(EdgeInsets(top: MindMorySpacing.xs, leading: MindMorySpacing.sm, bottom: MindMorySpacing.xs, trailing: MindMorySpacing.sm))
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(MindMorySpacing.sm)
        .background(MindMoryColors.background)
        .clipShape(shape)
        .overlay(shape.stroke(MindMoryColors.border))
    }

    private func openBaseTextEditor(sectionId: UUID, index: Int, existingText: MemoryAlbumTextSection?) {
        selectedBaseCellSectionID = sectionId
        selectedBaseCellIndex = index
        let textSection = existingText ?? MemoryAlbumTextSection(
            templateVariant: 0,
            blockType: .titleAndDescription,
            horizontalAlignment: .leading,
            verticalAlignment: .top,
            isTitleFirst: true,
            title: "A memory headline",
            description: "Describe this memory section with context and feelings.",
            style: .default
        )

        selectedBaseTextBlockType = textSection.blockType
        selectedBaseTextHorizontalAlignment = textSection.horizontalAlignment
        selectedBaseTextVerticalAlignment = textSection.verticalAlignment
        selectedBaseTextIsTitleFirst = textSection.isTitleFirst
        selectedBaseTitle = textSection.title
        selectedBaseDescription = textSection.description
        selectedBaseTitleSize = textSection.style.titleSize
        selectedBaseDescriptionSize = textSection.style.descriptionSize
        selectedBaseTitleWeight = textSection.style.titleWeight
        selectedBaseDescriptionWeight = textSection.style.descriptionWeight
        isShowingBaseTextEditor = true
    }

    private func updateBaseTextCell() {
        guard let sectionId = selectedBaseCellSectionID,
              let index = selectedBaseCellIndex
        else { return }

        let updatedTextSection = MemoryAlbumTextSection(
            templateVariant: 0,
            blockType: selectedBaseTextBlockType,
            horizontalAlignment: selectedBaseTextHorizontalAlignment,
            verticalAlignment: selectedBaseTextVerticalAlignment,
            isTitleFirst: selectedBaseTextIsTitleFirst,
            title: selectedBaseTitle,
            description: selectedBaseDescription,
            style: MemoryAlbumTextStyle(
                titleSize: selectedBaseTitleSize,
                descriptionSize: selectedBaseDescriptionSize,
                titleWeight: selectedBaseTitleWeight,
                descriptionWeight: selectedBaseDescriptionWeight
            )
        )

        viewModel.updateBaseSectionCell(
            sectionId: sectionId,
            index: index,
            content: .text(updatedTextSection)
        )

        selectedBaseCellSectionID = nil
        selectedBaseCellIndex = nil
        isShowingBaseTextEditor = false
    }

    private func baseTextEditorControls() -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            controlRow(title: "Content", values: MemoryAlbumTextBlockType.allCases, selected: selectedBaseTextBlockType) { type in
                selectedBaseTextBlockType = type
            }

            controlRow(title: "Horizontal", values: MemoryAlbumTextHorizontalAlignment.allCases, selected: selectedBaseTextHorizontalAlignment) { alignment in
                selectedBaseTextHorizontalAlignment = alignment
            }

            controlRow(title: "Vertical", values: MemoryAlbumTextVerticalAlignment.allCases, selected: selectedBaseTextVerticalAlignment) { alignment in
                selectedBaseTextVerticalAlignment = alignment
            }

            if selectedBaseTextBlockType == .titleAndDescription {
                HStack(spacing: MindMorySpacing.sm) {
                    FilterChip(title: "Title first", isSelected: selectedBaseTextIsTitleFirst) {
                        selectedBaseTextIsTitleFirst = true
                    }

                    FilterChip(title: "Description first", isSelected: !selectedBaseTextIsTitleFirst) {
                        selectedBaseTextIsTitleFirst = false
                    }
                }
            }

            if selectedBaseTextBlockType != .descriptionOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Title")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    TextField("Enter title", text: $selectedBaseTitle)
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

            if selectedBaseTextBlockType != .titleOnly {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("Description")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    TextField("Enter description", text: $selectedBaseDescription, axis: .vertical)
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

            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                Text("Typography")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textPrimary)

                if selectedBaseTextBlockType != .descriptionOnly {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text("Title size: \(Int(selectedBaseTitleSize))")
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        Slider(value: $selectedBaseTitleSize, in: 18...44, step: 1)

                        controlRow(title: "Title weight", values: MemoryAlbumTextWeight.allCases, selected: selectedBaseTitleWeight) { selectedWeight in
                            selectedBaseTitleWeight = selectedWeight
                        }
                    }
                }

                if selectedBaseTextBlockType != .titleOnly {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text("Description size: \(Int(selectedBaseDescriptionSize))")
                            .font(MindMoryTypography.caption)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        Slider(value: $selectedBaseDescriptionSize, in: 12...28, step: 1)

                        controlRow(title: "Description weight", values: MemoryAlbumTextWeight.allCases, selected: selectedBaseDescriptionWeight) { selectedWeight in
                            selectedBaseDescriptionWeight = selectedWeight
                        }
                    }
                }
            }
        }
    }

    private var baseCellTextEditorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    baseTextEditorControls()

                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Preview")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textPrimary)

                        MemoryAlbumTextSectionRenderView(
                            textSection: MemoryAlbumTextSection(
                                templateVariant: 0,
                                blockType: selectedBaseTextBlockType,
                                horizontalAlignment: selectedBaseTextHorizontalAlignment,
                                verticalAlignment: selectedBaseTextVerticalAlignment,
                                isTitleFirst: selectedBaseTextIsTitleFirst,
                                title: selectedBaseTitle,
                                description: selectedBaseDescription,
                                style: MemoryAlbumTextStyle(
                                    titleSize: selectedBaseTitleSize,
                                    descriptionSize: selectedBaseDescriptionSize,
                                    titleWeight: selectedBaseTitleWeight,
                                    descriptionWeight: selectedBaseDescriptionWeight
                                )
                            ),
                            isPreview: true
                        )
                        .frame(height: 180)
                    }
                }
                .padding(MindMorySpacing.xl)
            }
            .navigationTitle("Add Text Cell")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateBaseTextCell()
                    }
                    .disabled(selectedBaseTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingBaseTextEditor = false
                        selectedBaseCellSectionID = nil
                        selectedBaseCellIndex = nil
                    }
                }
            }
        }
    }

    private func overlayRotations(for count: Int) -> [Angle] {
        switch count {
        case 2:
            return [.degrees(-12), .degrees(10)]
        case 3:
            return [.degrees(-14), .degrees(6), .degrees(-8)]
        case 4:
            return [.degrees(-16), .degrees(8), .degrees(-6), .degrees(12)]
        case 5:
            return [.degrees(-16), .degrees(10), .degrees(-4), .degrees(8), .degrees(-10)]
        default:
            return Array(repeating: .degrees(0), count: count)
        }
    }

    private func overlayPositions(for count: Int, in size: CGSize) -> [CGSize] {
        let baseX = size.width * 0.12
        let baseY = size.height * 0.05

        switch count {
        case 2:
            return [CGSize(width: -baseX * 1.1, height: baseY * 1.4), CGSize(width: baseX * 1.2, height: -baseY)]
        case 3:
            return [CGSize(width: -baseX * 1.4, height: baseY * 1.3), CGSize(width: 0, height: -baseY * 1.5), CGSize(width: baseX * 1.6, height: baseY * 1.1)]
        case 4:
            return [CGSize(width: -baseX * 1.7, height: baseY * 1.2), CGSize(width: -baseX * 0.2, height: -baseY * 1.4), CGSize(width: baseX * 0.8, height: baseY * 0.8), CGSize(width: baseX * 1.8, height: baseY * 1.6)]
        case 5:
            return [CGSize(width: -baseX * 1.8, height: baseY * 1.4), CGSize(width: -baseX * 0.6, height: -baseY * 1.3), CGSize(width: 0, height: baseY * 0.1), CGSize(width: baseX * 1.1, height: baseY * 1.1), CGSize(width: baseX * 1.9, height: -baseY * 0.3)]
        default:
            return Array(repeating: .zero, count: count)
        }
    }
}

struct MemoryAlbumPreviewView: View {
    @ObservedObject var viewModel: MemoryAlbumViewModel
    let onSave: () -> Void
    let onCreate: (Album) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    Text("Album preview")
                        .font(MindMoryTypography.headingLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(viewModel.albumName)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textSecondary)

                    ForEach(viewModel.sections) { section in
                        Text(section.type.rawValue.capitalized)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    }
                }
                .padding(MindMorySpacing.xl)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
            .onChange(of: viewModel.savedAlbum) { _, newAlbum in
                if let album = newAlbum {
                    onCreate(album)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MemoryAlbumCreateView(viewModel: MemoryAlbumViewModel()) { _ in }
    }
}
