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
    @State private var isSectionDropTargetActive = false
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
                viewModel.addSection(section)
                isAddingSection = false
            }
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Create Memory Album")
        .navigationBarTitleDisplayMode(.inline)
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
            if !viewModel.sections.isEmpty {
                VStack(spacing: MindMorySpacing.sm) {
                    if viewModel.sections.count > 1 {
                        moveDropZone(
                            title: "Drag section here to move to top",
                            systemImage: "arrow.up.to.line"
                        ) { sourceId in
                            viewModel.moveSectionToTop(sourceId: sourceId)
                        }
                    }

                    ForEach(viewModel.sections) { section in
                        draggableSection(section)
                    }

                    if viewModel.sections.count > 1 {
                        moveDropZone(
                            title: "Drag section here to move to bottom",
                            systemImage: "arrow.down.to.line"
                        ) { sourceId in
                            viewModel.moveSectionToBottom(sourceId: sourceId)
                        }
                    }
                }
            }

            PrimaryButton(title: "Tambah Section") {
                isAddingSection = true
            }

            PrimaryButton(title: "Simpan Album") {
                viewModel.saveAlbum()
            }
            .disabled(viewModel.sections.isEmpty || viewModel.hasIncompleteSections)
        }
    }

    private func draggableSection(_ section: MemoryAlbumSection) -> some View {
        sectionCard(section)
            .overlay(alignment: .topTrailing) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(MindMoryColors.textSecondary)
                    .padding(MindMorySpacing.xs)
                    .background(MindMoryColors.surface)
                    .clipShape(Circle())
                    .padding(MindMorySpacing.xs)
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
            MemoryAlbumTextSectionRenderView(textSection: textSection, isPreview: true)
        }
    }

    private func moveDropZone(
        title: String,
        systemImage: String,
        onDropSection: @escaping (UUID) -> Void
    ) -> some View {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
            .stroke(MindMoryColors.border, style: StrokeStyle(lineWidth: 1, dash: [6]))
            .frame(height: 44)
            .overlay {
                HStack(spacing: MindMorySpacing.xs) {
                    Image(systemName: systemImage)
                    Text(title)
                        .font(MindMoryTypography.caption)
                }
                .foregroundStyle(MindMoryColors.textSecondary)
            }
            .dropDestination(for: String.self) { droppedItems, _ in
                guard
                    let rawValue = droppedItems.first,
                    let sourceId = UUID(uuidString: rawValue)
                else {
                    return false
                }

                onDropSection(sourceId)
                return true
            } isTargeted: { isTargeted in
                isSectionDropTargetActive = isTargeted
            }
            .opacity(isSectionDropTargetActive ? 0.85 : 1)
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
                Color(MindMoryColors.background)

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

    private func previousStep() {
        switch currentStep {
        case .details:
            break
        case .selectPhotos:
            currentStep = .details
        }
    }
}

#Preview {
    NavigationStack {
        MemoryAlbumCreateView(viewModel: MemoryAlbumViewModel()) { _ in }
    }
}
