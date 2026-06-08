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

    @ViewBuilder
    private func overlappedImageSection(_ section: MemoryAlbumSection, template: MemoryAlbumSectionLayoutTemplate, isPreview: Bool) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let widthFactor: CGFloat = template.layoutCount <= 3 ? 0.72 : 0.58
            let cardWidth = size.width * widthFactor
            let cardHeight = size.height * 0.82
            let positions = overlayPositions(for: template.layoutCount, in: size)
            let rotations = overlayRotations(for: template.layoutCount)

            ZStack {
                ForEach(0..<template.layoutCount, id: \.self) { index in
                    let card = photoCell(at: index, in: section, isPreview: isPreview)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .rotationEffect(rotations[index])
                        .offset(positions[index])
                        .zIndex(Double(index))

                    card
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    @ViewBuilder
    private func photoCell(at index: Int, in section: MemoryAlbumSection, isPreview: Bool) -> some View {
        sectionImageCell(at: index, in: section)
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
            style: existingTextSection.style
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

            if template.isOverlayStyle {
                overlappedImageSection(section, template: template, isPreview: true)
                    .frame(height: template.albumHeight)
            } else {
                MemoryAlbumSectionLayoutRenderer(template: template) { photoIndex in
                    previewImageCell(at: photoIndex, in: section)
                }
                .frame(height: template.albumHeight)
            }
        case .text(let textSection):
            MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: false)
                .frame(maxWidth: .infinity)
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

    @ViewBuilder
    private func overlappedImageSection(_ section: MemoryAlbumSection, template: MemoryAlbumSectionLayoutTemplate, isPreview: Bool) -> some View {
        GeometryReader { geometry in
            let size = geometry.size
            let widthFactor: CGFloat = template.layoutCount <= 3 ? 0.72 : 0.58
            let cardWidth = size.width * widthFactor
            let cardHeight = size.height * 0.82
            let positions = overlayPositions(for: template.layoutCount, in: size)
            let rotations = overlayRotations(for: template.layoutCount)

            ZStack {
                ForEach(0..<template.layoutCount, id: \.self) { index in
                    let card = photoCell(at: index, in: section, isPreview: isPreview)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
                        .rotationEffect(rotations[index])
                        .offset(positions[index])
                        .zIndex(Double(index))

                    card
                }
            }
            .frame(width: size.width, height: size.height)
        }
    }

    @ViewBuilder
    private func photoCell(at index: Int, in section: MemoryAlbumSection, isPreview: Bool) -> some View {
        previewImageCell(at: index, in: section)
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

#Preview("Graduation Album") {
    NavigationStack {
        MemoryAlbumCreateView(
            viewModel: MemoryAlbumViewModel(sampleSections: PreviewData.graduationAlbumSections)
        ) { _ in }
    }
}
