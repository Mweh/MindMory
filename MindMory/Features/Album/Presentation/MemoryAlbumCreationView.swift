import PhotosUI
import SwiftUI
import UIKit

struct MemoryAlbumCreationView: View {
    enum Step {
        case details
        case selectPhotos
    }

    @StateObject private var viewModel: MemoryAlbumCreationViewModel
    @State private var selectedCoverPhotoItem: PhotosPickerItem?
    @State private var selectedSectionPhotoItem: PhotosPickerItem?
    @State private var selectedPickerSectionID: UUID?
    @State private var selectedPickerIndex: Int?
    @State private var isAddingSection = false
    @State private var preconfiguredSection: MemoryAlbumSection? = nil
    
    @State private var selectedSectionID: UUID?
    @State private var selectedTextTitle: String = ""
    @State private var selectedTextDescription: String = ""
    @State private var isShowingTextEditor = false
    @State private var sectionInsertionIndex: Int?
    @State private var draggingSectionID: UUID?
    @State private var currentStep: Step = .details
    let onCreate: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    init(viewModel: MemoryAlbumCreationViewModel, onCreate: @escaping (Album) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreate = onCreate
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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

                    if currentStep == .selectPhotos {
                        footerButtons
                    }
                }
                .padding(MindMorySpacing.xl)
            }
            .onTapGesture {
                draggingSectionID = nil
            }
            // Floating add-section button when building sections
            if currentStep == .selectPhotos {
                floatingMenuButton
                    .padding(.trailing, MindMorySpacing.xl)
                    .padding(.bottom, MindMorySpacing.xl)
            }
        }
        .navigationDestination(isPresented: $isAddingSection) {
            MemoryAlbumSectionCreateView(existingSection: preconfiguredSection) { section in
                if let index = sectionInsertionIndex {
                    viewModel.insertSection(section, at: index)
                } else {
                    viewModel.addSection(section)
                }

                // Select the newly added section so UI state updates accordingly
                selectedSectionID = section.id
                if case .image = section.content {
                    selectedPickerIndex = 0
                }

                sectionInsertionIndex = nil
                isAddingSection = false
                preconfiguredSection = nil
            }
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
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // Leading back control: if on selectPhotos, go back to details; otherwise dismiss
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if currentStep == .selectPhotos {
                        currentStep = .details
                        return
                    }

                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
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

                await MainActor.run {
                    viewModel.updateSectionPhoto(from: [data], sectionId: sectionId, index: index)
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
                        MemoryImagePlaceholderView(
                            image: viewModel.coverPhoto?.uiImage,
                            imageName: nil,
                            placeholderIcon: "photo.on.rectangle",
                            placeholderText: viewModel.coverPhoto.map { _ in "Tap to change cover photo" } ?? "Tap to add cover photo"
                        )
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                .stroke(MindMoryColors.border)
                        )
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Album date")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Picker("Album date type", selection: $viewModel.isDateRange) {
                        Text("Single day").tag(false)
                        Text("Range").tag(true)
                    }
                    .pickerStyle(.segmented)

                    DatePicker(
                        "Start date",
                        selection: $viewModel.albumDateStart,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)

                    if viewModel.isDateRange {
                        DatePicker(
                            "End date",
                            selection: $viewModel.albumDateEnd,
                            in: viewModel.albumDateStart...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                    }
                }
            }
            PrimaryButton(title: primaryButtonTitle, action: primaryButtonAction)
                .disabled(primaryButtonDisabled)
                .frame(maxWidth: .infinity)
                .padding(.top, MindMorySpacing.md)
        }
    }

    private var selectPhotosStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            // Album header (cover + title + date) shown above the sections
            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                    Text(viewModel.albumName.isEmpty ? "Untitled memory" : viewModel.albumName)
                        .font(MindMoryTypography.headingLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    if let coverPhoto = viewModel.coverPhoto, let image = coverPhoto.uiImage {
                        MemoryImagePlaceholderView(image: image, imageName: nil)
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                    } else {
                        MemoryImagePlaceholderView(image: nil, imageName: nil)
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                                    .stroke(MindMoryColors.border)
                            )
                    }

                    HStack(spacing: MindMorySpacing.md) {
                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text(viewModel.albumDate.displayText)
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.textSecondary)

                            Text("\(photoCount) photo(s)")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.primaryGreen)
                        }

                        Spacer()
                    }
                }
            }

            ForEach(viewModel.sections) { section in
                draggableSection(section)
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
        MemoryAlbumSectionView(section: section, isPreview: false) { index, section in
            PhotosPicker(
                selection: bindingForSectionPhoto(sectionId: section.id, index: index),
                matching: .images,
                photoLibrary: .shared()
            ) {
                AlbumSectionPhotoCell(image: imageForSectionCell(index: index, section: section))
            }
            .buttonStyle(.plain)
        }
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

    private var photoCount: Int {
        viewModel.sections.reduce(0) { result, section in
            guard case .image(_, _, let photos) = section.content else { return result }
            return result + photos.compactMap { $0 }.count
        } + (viewModel.coverPhoto != nil ? 1 : 0)
    }

    private var floatingActionButton: some View {
        Button {
            sectionInsertionIndex = nil
            isAddingSection = true
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(MindMoryColors.primaryGreen)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add section")
    }

    private var floatingMenuButton: some View {
        Menu {
            Button(action: {
                // Add image section (default single layout)
                preconfiguredSection = MemoryAlbumSection(layoutCount: 1)
                sectionInsertionIndex = nil
                isAddingSection = true
            }) {
                Label("Add Image", systemImage: "photo.on.rectangle")
            }

            Button(action: {
                // Add text section
                let defaultText = MemoryAlbumTextSection(
                    templateVariant: 0,
                    blockType: .titleAndDescription,
                    horizontalAlignment: .leading,
                    verticalAlignment: .top,
                    isTitleFirst: true,
                    title: "",
                    description: "",
                    style: MemoryAlbumTextStyle.default
                )
                preconfiguredSection = MemoryAlbumSection(textSection: defaultText)
                sectionInsertionIndex = nil
                isAddingSection = true
            }) {
                Label("Add Text", systemImage: "text.bubble")
            }
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(MindMoryColors.primaryGreen)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var footerButtons: some View {
        HStack(spacing: MindMorySpacing.sm) {
            PrimaryButton(title: primaryButtonTitle, action: primaryButtonAction)
                .disabled(primaryButtonDisabled)
                .frame(maxWidth: .infinity)
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
            return false
        case .selectPhotos:
            return viewModel.sections.isEmpty || !viewModel.hasImageSections || viewModel.hasIncompleteSections
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

#Preview("Graduation Album") {
    NavigationStack {
        MemoryAlbumCreationView(
            viewModel: MemoryAlbumCreationViewModel(sampleSections: PreviewData.graduationAlbumSections)
        ) { _ in }
    }
}
