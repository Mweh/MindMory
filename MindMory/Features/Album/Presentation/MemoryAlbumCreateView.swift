import PhotosUI
import SwiftUI
import UIKit

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
            .background(
                Group {
                    if isDimmed {
                        Color.black.opacity(0.04)
                    } else {
                        Color.clear
                    }
                }
            )
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
                    return false
                }

                viewModel.moveSection(sourceId: sourceId, destinationId: section.id)
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

            MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                sectionImageCell(at: photoIndex, in: section)
            }
            .frame(height: template.albumHeight)
        case .text(let textSection):
            if textSection.isAdaptive {
                AdaptiveTextSectionView(
                    textSection: textSection,
                    isSelected: selectedSectionID == section.id,
                    onUpdate: { updatedTextSection in
                        viewModel.updateSection(
                            MemoryAlbumSection(id: section.id, textSection: updatedTextSection)
                        )
                    },
                    onEdit: {
                        selectedSectionID = section.id
                        syncSelectedTextSection()
                        isShowingTextEditor = true
                    },
                    onDelete: {
                        viewModel.removeSection(id: section.id)
                        if selectedSectionID == section.id {
                            selectedSectionID = viewModel.sections.first?.id
                        }
                    }
                )
            } else {
                MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: true)
            }
        case .shape(let shapeSection):
            AdaptiveShapeSectionView(
                shapeSection: shapeSection,
                isSelected: selectedSectionID == section.id,
                onUpdate: { updatedShape in
                    viewModel.updateSection(
                        MemoryAlbumSection(id: section.id, content: .shape(updatedShape))
                    )
                },
                onDelete: {
                    viewModel.removeSection(id: section.id)
                    if selectedSectionID == section.id {
                        selectedSectionID = viewModel.sections.first?.id
                    }
                }
            )
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

    private func imageForSectionCell(index: Int, section: MemoryAlbumSection) -> UIImage? {
        guard case .image(_, _, let photos) = section.content else { return nil }
        guard photos.indices.contains(index) else { return nil }
        guard let photo = photos[index] else { return nil }
        return photo.uiImage
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

    private var footerButtons: some View {
        HStack(spacing: MindMorySpacing.sm) {
            if currentStep != .details {
                Button {
                    previousStep()
                } label: {
                    Text("Back")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)
                        .padding(.vertical, MindMorySpacing.sm)
                        .frame(maxWidth: .infinity)
                        .background(MindMoryColors.surface)
                        .cornerRadius(MindMoryRadius.large)
                }
            }

            PrimaryButton(title: primaryButtonTitle, action: primaryButtonAction)
                .disabled(primaryButtonDisabled)
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case .details:
            return "Step 1"
        case .selectPhotos:
            return "Step 2"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case .details:
            return "Memory title and cover photo"
        case .selectPhotos:
            return "Build sections and save your memory album"
        }
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case .details:
            return "Continue"
        case .selectPhotos:
            return "Simpan Album"
        }
    }

    private var primaryButtonDisabled: Bool {
        switch currentStep {
        case .details:
            return viewModel.isSaveButtonDisabled
        case .selectPhotos:
            return viewModel.sections.isEmpty || viewModel.hasIncompleteSections
        }
    }

    private func primaryButtonAction() {
        switch currentStep {
        case .details:
            currentStep = .selectPhotos
        case .selectPhotos:
            viewModel.saveAlbum()
        }
    }


    private func selectedSectionState() -> MemoryAlbumSection? {
        guard let selectedSectionID = selectedSectionID else { return nil }
        return viewModel.sections.first(where: { $0.id == selectedSectionID })
    }

    private var selectedSection: MemoryAlbumSection? {
        selectedSectionState()
    }

    private func syncSelectedTextSection() {
        guard let selectedSection = selectedSection,
              case .text(let textSection) = selectedSection.content
        else {
            return
        }

        selectedTextTitle = textSection.title
        selectedTextDescription = textSection.description
    }

    private func updateSelectedTextSection() {
        guard let selectedSection = selectedSection,
              case .text(let existingTextSection) = selectedSection.content
        else {
            return
        }

        let updatedTextSection = MemoryAlbumTextSection(
            templateVariant: existingTextSection.templateVariant,
            blockType: existingTextSection.blockType,
            horizontalAlignment: existingTextSection.horizontalAlignment,
            verticalAlignment: existingTextSection.verticalAlignment,
            isTitleFirst: existingTextSection.isTitleFirst,
            title: selectedTextTitle,
            description: selectedTextDescription,
            style: existingTextSection.style,
            isAdaptive: existingTextSection.isAdaptive,
            offset: existingTextSection.offset,
            scale: existingTextSection.scale
        )

        viewModel.updateSection(
            MemoryAlbumSection(id: selectedSection.id, textSection: updatedTextSection)
        )
    }

    private var sectionTextEditorSheet: some View {
        NavigationStack {
            if let selectedSection = selectedSection,
               case .text = selectedSection.content {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Title")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.textSecondary)

                        TextField("Enter title", text: $selectedTextTitle)
                            .font(MindMoryTypography.bodyMedium)
                            .padding(MindMorySpacing.sm)
                            .background(MindMoryColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
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
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                    .stroke(MindMoryColors.border)
                            )
                    }

                    Spacer()
                }
                .padding(MindMorySpacing.xl)
                .navigationTitle("Edit Text Section")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            updateSelectedTextSection()
                            isShowingTextEditor = false
                        }
                        .disabled(selectedTextTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isShowingTextEditor = false
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    private func previousStep() {
        switch currentStep {
        case .details:
            break
        case .selectPhotos:
            currentStep = .details
        }
    }
}

@ViewBuilder
private func shapeSectionView(_ shapeSection: MemoryAlbumShapeSection) -> some View {
    let fillColor = shapeSection.style.fillColor.opacity(shapeSection.style.opacity)
    let strokeColor = shapeSection.style.borderColor
    let lineWidth = shapeSection.style.borderWidth
    let blend = blendMode(for: shapeSection.style.blendMode)

    switch shapeSection.type {
    case .rectangle:
        Rectangle()
            .fill(fillColor)
            .blendMode(blend)
            .overlay(Rectangle().stroke(strokeColor, lineWidth: lineWidth))
    case .roundedRectangle:
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(fillColor)
            .blendMode(blend)
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(strokeColor, lineWidth: lineWidth))
    case .circle:
        Circle()
            .fill(fillColor)
            .blendMode(blend)
            .overlay(Circle().stroke(strokeColor, lineWidth: lineWidth))
    case .capsule:
        Capsule()
            .fill(fillColor)
            .blendMode(blend)
            .overlay(Capsule().stroke(strokeColor, lineWidth: lineWidth))
    case .diamond:
        DiamondShape()
            .fill(fillColor)
            .blendMode(blend)
            .overlay(DiamondShape().stroke(strokeColor, lineWidth: lineWidth))
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

private struct AdaptiveTextSectionView: View {
    let textSection: MemoryAlbumTextSection
    let isSelected: Bool
    let onUpdate: (MemoryAlbumTextSection) -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @GestureState private var isPressing: Bool = false

    private var isActive: Bool {
        isSelected || isPressing
    }

    var body: some View {
        MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: true)
            .fixedSize(horizontal: true, vertical: false)
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .strokeBorder(isActive ? MindMoryColors.primaryGreen : Color.clear, lineWidth: isActive ? 1.8 : 0)
            )
            .scaleEffect(scale)
            .contentShape(Rectangle())
            .overlay(
                Group {
                    if isActive {
                        VStack(spacing: MindMorySpacing.xs) {
                            HStack(spacing: MindMorySpacing.sm) {
                                Button {
                                    onEdit()
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(MindMoryColors.textPrimary)
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }

                                Button {
                                    onDelete()
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(MindMoryColors.error)
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }
                            }

                            HStack(spacing: MindMorySpacing.sm) {
                                Button {
                                    withAnimation(.easeInOut) {
                                        scale = max(0.5, scale - 0.1)
                                        updateTextSectionScale()
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }

                                Button {
                                    withAnimation(.easeInOut) {
                                        scale = min(2.0, scale + 0.1)
                                        updateTextSectionScale()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(6)
                        .background(MindMoryColors.background.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            Text("Hold and drag to move")
                                .font(MindMoryTypography.caption)
                                .foregroundStyle(MindMoryColors.textSecondary)
                                .padding(.top, 34)
                        )
                    }
                }
                , alignment: .topTrailing
            )
            .overlay(
                Group {
                    if isActive {
                        Circle()
                            .fill(MindMoryColors.surface)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(MindMoryColors.textPrimary)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                            .padding(4)
                            .accessibilityLabel("Resize text")
                    }
                }
                , alignment: .bottomTrailing
            )
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .highPriorityGesture(pressDragGesture)
            .shadow(color: Color.black.opacity(isActive ? 0.12 : 0.06), radius: 10, x: 0, y: 5)
            .zIndex(isActive ? 1 : 0)
            .onAppear {
                offset = textSection.offset
                scale = textSection.scale
            }
            .onChange(of: textSection.offset) { newOffset in
                offset = newOffset
            }
            .onChange(of: textSection.scale) { newScale in
                scale = newScale
            }
    }

    private var pressDragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.18)
            .updating($isPressing) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .sequenced(before: DragGesture())
            .onChanged { value in
                switch value {
                case .second(_, let drag?):
                    dragOffset = drag.translation
                default:
                    break
                }
            }
            .onEnded { value in
                switch value {
                case .second(_, let drag?):
                    offset.width += drag.translation.width
                    offset.height += drag.translation.height
                default:
                    break
                }
                dragOffset = .zero
                updateTextSectionOffset()
            }
    }

    private func updateTextSectionOffset() {
        let updated = MemoryAlbumTextSection(
            templateVariant: textSection.templateVariant,
            blockType: textSection.blockType,
            horizontalAlignment: textSection.horizontalAlignment,
            verticalAlignment: textSection.verticalAlignment,
            isTitleFirst: textSection.isTitleFirst,
            title: textSection.title,
            description: textSection.description,
            style: textSection.style,
            isAdaptive: textSection.isAdaptive,
            offset: offset,
            scale: scale
        )

        onUpdate(updated)
    }

    private func updateTextSectionScale() {
        updateTextSectionOffset()
    }
}

private struct AdaptiveShapeSectionView: View {
    let shapeSection: MemoryAlbumShapeSection
    let isSelected: Bool
    let onUpdate: (MemoryAlbumShapeSection) -> Void
    let onDelete: () -> Void

    @State private var offset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero
    @State private var scale: CGFloat = 1
    @GestureState private var isPressing: Bool = false

    private var isActive: Bool {
        isSelected || isPressing
    }

    var body: some View {
        shapeSectionView(shapeSection)
            .frame(width: 220 * scale, height: 220 * scale)
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .stroke(isActive ? MindMoryColors.primaryGreen : Color.clear, lineWidth: isActive ? 2 : 0)
            )
            .contentShape(Rectangle())
            .overlay(
                Group {
                    if isActive {
                        VStack(spacing: MindMorySpacing.xs) {
                            HStack(spacing: MindMorySpacing.sm) {
                                Button {
                                    withAnimation(.easeInOut) {
                                        scale = max(0.5, scale - 0.1)
                                        updateShapeSectionSize()
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }

                                Button {
                                    withAnimation(.easeInOut) {
                                        scale = min(2.0, scale + 0.1)
                                        updateShapeSectionSize()
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .semibold))
                                        .padding(8)
                                        .background(MindMoryColors.surface)
                                        .clipShape(Circle())
                                }
                            }

                            Button {
                                onDelete()
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(MindMoryColors.error)
                                    .padding(8)
                                    .background(MindMoryColors.surface)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(6)
                        .background(MindMoryColors.background.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            Text("Hold and drag to move")
                                .font(MindMoryTypography.caption)
                                .foregroundStyle(MindMoryColors.textSecondary)
                                .padding(.top, 34)
                        )
                    }
                }
                , alignment: .topTrailing
            )
            .overlay(
                Group {
                    if isActive {
                        Circle()
                            .fill(MindMoryColors.surface)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(MindMoryColors.textPrimary)
                            )
                            .shadow(color: Color.black.opacity(0.08), radius: 1, x: 0, y: 1)
                            .padding(4)
                            .accessibilityLabel("Resize shape")
                    }
                }
                , alignment: .bottomTrailing
            )
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .highPriorityGesture(pressDragGesture)
            .shadow(color: Color.black.opacity(isActive ? 0.16 : 0.07), radius: 10, x: 0, y: 5)
            .zIndex(isActive ? 1 : 0)
            .onAppear {
                offset = shapeSection.offset
                scale = shapeSection.scale
            }
            .onChange(of: shapeSection.offset) { newOffset in
                offset = newOffset
            }
            .onChange(of: shapeSection.scale) { newScale in
                scale = newScale
            }
    }

    private var pressDragGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.18)
            .updating($isPressing) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .sequenced(before: DragGesture())
            .onChanged { value in
                switch value {
                case .second(_, let drag?):
                    dragOffset = drag.translation
                default:
                    break
                }
            }
            .onEnded { value in
                switch value {
                case .second(_, let drag?):
                    offset.width += drag.translation.width
                    offset.height += drag.translation.height
                default:
                    break
                }
                dragOffset = .zero
                updateShapeSectionSize()
            }
    }

    private func updateShapeSectionSize() {
        onUpdate(
            MemoryAlbumShapeSection(
                type: shapeSection.type,
                style: shapeSection.style,
                offset: offset,
                scale: scale
            )
        )
    }
}

private struct MemoryAlbumPreviewView: View {
    @ObservedObject var viewModel: MemoryAlbumViewModel
    let onSave: () -> Void
    let onCreate: (Album) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                previewHeader

                if viewModel.sections.isEmpty {
                    Text("No sections added yet.")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(MindMorySpacing.md)
                        .background(MindMoryColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                } else {
                    VStack(spacing: MindMorySpacing.lg) {
                        ForEach(viewModel.sections) { section in
                            previewSectionCard(section)
                        }
                    }
                }

                PrimaryButton(title: "Simpan Album") {
                    onSave()
                }
                .disabled(viewModel.sections.isEmpty || viewModel.hasIncompleteSections || viewModel.isSaveButtonDisabled)
            }
            .padding(MindMorySpacing.xl)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
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
    }

    private var previewHeader: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text(viewModel.albumName.isEmpty ? "Untitled memory" : viewModel.albumName)
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)

            if let coverPhoto = viewModel.coverPhoto, let image = coverPhoto.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(MindMoryRadius.large)
            } else {
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .fill(MindMoryColors.surface)
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(MindMoryColors.textSecondary)
                    )
            }
        }
    }

    @ViewBuilder
    private func previewSectionCard(_ section: MemoryAlbumSection) -> some View {
        switch section.content {
        case .image(let layoutCount, let layoutVariant, _):
            let template = MemoryAlbumSectionLayoutCatalog.template(layoutCount: layoutCount, variant: layoutVariant)

            MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                previewImageCell(at: photoIndex, in: section)
            }
            .frame(height: template.albumHeight)
        case .text(let textSection):
            MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: false)
                .frame(maxWidth: .infinity)
        case .shape(let shapeSection):
            ZStack {
                shapeSectionView(shapeSection)
                    .frame(width: 220 * shapeSection.scale, height: 220 * shapeSection.scale)
                    .offset(shapeSection.offset)
            }
            .frame(height: 260)
        }
    }

    @ViewBuilder
    private func previewImageCell(at index: Int, in section: MemoryAlbumSection) -> some View {
        let shape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        ZStack {
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
    }

    private func imageForSectionCell(index: Int, section: MemoryAlbumSection) -> UIImage? {
        guard case .image(_, _, let photos) = section.content else { return nil }
        guard photos.indices.contains(index) else { return nil }
        guard let photo = photos[index] else { return nil }
        return photo.uiImage
    }
}

#Preview {
    NavigationStack {
        MemoryAlbumCreateView(viewModel: MemoryAlbumViewModel()) { _ in }
    }
}
