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
    @State private var selectedTemplateID: UUID? = nil
    @State private var albumTemplates: [MemoryAlbumTemplate] = [
        MemoryAlbumTemplate(
            title: "Birthday album",
            subtitle: "Bright colors, playful layouts, and a joyful story.",
            suggestedName: "Birthday Moments",
            note: "Capture the celebration, cake, and candid smiles.",
            iconName: "gift.fill",
            accent: MindMoryColors.Surface.primary,
            sections: [
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 0,
                    blockType: .titleAndDescription,
                    horizontalAlignment: .center,
                    verticalAlignment: .top,
                    isTitleFirst: true,
                    title: "Birthday Highlights",
                    description: "A joyful album to showcase the cake, laughter, and moments worth celebrating.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 1, layoutVariant: 0, photos: [nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 1,
                    blockType: .descriptionOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: false,
                    title: "",
                    description: "Candles, wishes, and the spark of every surprise — a bright start to the day.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 2, layoutVariant: 0, photos: [nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 2,
                    blockType: .titleOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: true,
                    title: "Celebrate the day",
                    description: "",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 3, layoutVariant: 1, photos: [nil, nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 0,
                    blockType: .titleAndDescription,
                    horizontalAlignment: .leading,
                    verticalAlignment: .top,
                    isTitleFirst: true,
                    title: "The moments that matter",
                    description: "Share the feeling of the day with heartfelt captions and the people who made it special.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 4, layoutVariant: 3, photos: [nil, nil, nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 1,
                    blockType: .descriptionOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: false,
                    title: "",
                    description: "End with the glow of celebration, the laughter shared, and the wishes that linger on.",
                    style: .default
                ))
            ]
        ),
        MemoryAlbumTemplate(
            title: "Graduation album",
            subtitle: "Elegant layouts for caps, speeches, and celebration.",
            suggestedName: "Graduation Day",
            note: "Frame the achievement with ceremony, family, and the moment you turned the page.",
            iconName: "graduationcap.fill",
            accent: MindMoryColors.Surface.primary,
            sections: [
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 0,
                    blockType: .titleAndDescription,
                    horizontalAlignment: .leading,
                    verticalAlignment: .top,
                    isTitleFirst: true,
                    title: "Graduation Day",
                    description: "A polished album layout designed to capture the ceremony, the cheers, and the proud moments.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 1, layoutVariant: 0, photos: [nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 1,
                    blockType: .descriptionOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: false,
                    title: "",
                    description: "From the procession to the proud smiles, keep the detail of the day and the people who were there.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 2, layoutVariant: 2, photos: [nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 0,
                    blockType: .titleAndDescription,
                    horizontalAlignment: .center,
                    verticalAlignment: .top,
                    isTitleFirst: true,
                    title: "Caps, gowns, and proud looks",
                    description: "Highlight the ceremony energy, the applause, and the quiet moments between every milestone.",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 3, layoutVariant: 2, photos: [nil, nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 2,
                    blockType: .titleOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: true,
                    title: "Family cheers",
                    description: "",
                    style: .default
                )),
                MemoryAlbumSection(layoutCount: 4, layoutVariant: 3, photos: [nil, nil, nil, nil]),
                MemoryAlbumSection(textSection: MemoryAlbumTextSection(
                    templateVariant: 1,
                    blockType: .descriptionOnly,
                    horizontalAlignment: .leading,
                    verticalAlignment: .center,
                    isTitleFirst: false,
                    title: "",
                    description: "Finish with warm congratulations, the feeling of accomplishment, and the start of the next chapter.",
                    style: .default
                ))
            ]
        ),
        MemoryAlbumTemplate(
            title: "Custom album",
            subtitle: "Start fresh and build your own story from scratch.",
            suggestedName: "Custom album",
            note: "Add sections and photos in the order that matters most to you.",
            iconName: "sparkles",
            accent: MindMoryColors.Surface.primary,
            sections: MemoryAlbumCreationViewModel.defaultSections
        )
    ]
    
    @State private var selectedSectionID: UUID?
    @State private var selectedTextTitle: String = ""
    @State private var selectedTextDescription: String = ""
    @State private var isShowingTextEditor = false
    @State private var sectionInsertionIndex: Int?
    @FocusState private var isAlbumTitleFocused: Bool
    @FocusState private var isSectionTextTitleFocused: Bool
    @FocusState private var isSectionTextDescriptionFocused: Bool
    @State private var draggingSectionID: UUID?
    @State private var currentStep: Step
    let onCreate: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    init(viewModel: MemoryAlbumCreationViewModel, onCreate: @escaping (Album) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _currentStep = State(initialValue: viewModel.isEditMode ? .details : .details)
        self.onCreate = onCreate
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageLayout(
                padding: EdgeInsets(
                    top: MindMorySpacing.xl,
                    leading: MindMorySpacing.xl,
                    bottom: MindMorySpacing.xl,
                    trailing: MindMorySpacing.xl
                )
            ) {
                    ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
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
                    .padding(.bottom, MindMorySpacing.xl)
                }
            }
            .onTapGesture {
                UIApplication.shared.dismissKeyboard()
                draggingSectionID = nil
            }

            if currentStep == .selectPhotos {
                floatingMenuButton
                    .padding(.trailing, MindMorySpacing.xl)
                    .padding(.bottom, MindMorySpacing.xl)
            }
        }
        .overlay {
            if viewModel.isProcessing {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(24)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                }
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
        .onChange(of: selectedSectionID) { _ in
            syncSelectedTextSection()
        }
        .onChange(of: viewModel.sections) { _ in
            if currentStep == .selectPhotos, selectedSectionID == nil {
                selectedSectionID = viewModel.sections.first?.id
            }
            syncSelectedTextSection()
        }
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
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
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

    private var detailsStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            coverPhotoSection

            albumTitleSection

            if !viewModel.isEditMode {
                albumTemplateSection
            }

            PrimaryButton(title: primaryButtonTitle, action: primaryButtonAction)
                .disabled(isDetailsStepDisabled || viewModel.isProcessing)
                .frame(maxWidth: .infinity)
                .padding(.top, MindMorySpacing.md)
        }
    }

    private var coverPhotoSection: some View {
        PhotosPicker(
            selection: $selectedCoverPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                ImagePlaceholder(
                    image: viewModel.coverPhoto?.uiImage,
                    title: "Your Story Starts Here",
                    subtitle: "Tap to select a cover that defines your collection"
                )
                .frame(height: 240)

                if viewModel.coverPhoto != nil {
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .fill(Color.black.opacity(0.24))
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))

                    VStack(spacing: MindMorySpacing.xs) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Change cover photo")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Surface.background)
                    }
                    .padding(MindMorySpacing.md)
                    .background(Color.black.opacity(0.24))
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    .padding(MindMorySpacing.lg)
                    .frame(maxHeight: .infinity, alignment: .bottomLeading)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var albumTitleSection: some View {
        TextFieldComponent(
            title: "Album title",
            iconName: "pencil.tip",
            borderColor: viewModel.albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? MindMoryColors.Content.secondary.opacity(0.2) : MindMoryColors.Surface.primary.opacity(0.6)
        ) {
            TextField("Name your album", text: $viewModel.albumName)
                .focused($isAlbumTitleFocused)
                .submitLabel(.done)
                .onSubmit {
                    UIApplication.shared.dismissKeyboard()
                }
        }
    }

    private var albumTemplateSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Album templates",
                size: .small
            )

            VStack(spacing: MindMorySpacing.md) {
                ForEach(albumTemplates) { template in
                        MemoryAlbumTemplateCard(
                            template: template,
                            isSelected: template.id == selectedTemplateID
                        ) {
                            // Make selection sticky: selecting a template always applies it
                            // and we do not allow toggling back to a "no selection" state.
                            selectedTemplateID = template.id
                            viewModel.applyTemplate(
                                note: template.note,
                                sections: template.sections
                            )
                        }
                }
            }
        }
    }

    private var isDetailsStepDisabled: Bool {
        let missingNameOrCover = viewModel.albumName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.coverPhoto == nil
        // When creating (not editing), require a template to be selected as well
        if !viewModel.isEditMode {
            return missingNameOrCover || selectedTemplateID == nil
        }

        return missingNameOrCover
    }

    private var selectPhotosStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
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
                        .font(MindMoryTypography.labelSmall)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                        .padding(MindMorySpacing.sm)
                        .background(MindMoryColors.Surface.surface)
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
                        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                            .stroke(MindMoryColors.Surface.primary.opacity(0.6), style: StrokeStyle(lineWidth: 3, dash: [6]))
                    }
                }
            )
            .contentShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
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
                .font(MindMoryTypography.labelLarge)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(MindMoryColors.Surface.primary)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    private var footerButtons: some View {
        HStack(spacing: MindMorySpacing.sm) {
            PrimaryButton(title: primaryButtonTitle, action: primaryButtonAction)
                .disabled(primaryButtonDisabled || viewModel.isProcessing)
                .frame(maxWidth: .infinity)
        }
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case .details:
            return "Continue"
        case .selectPhotos:
            return viewModel.isEditMode ? "Save changes" : "Save album"
        }
    }

    private var navigationTitle: String {
        switch currentStep {
        case .details:
            return viewModel.isEditMode ? "Edit album" : "Create an album"
        case .selectPhotos:
            return viewModel.isEditMode ? "Edit album photos" : "Select album photos"
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
                            .foregroundStyle(MindMoryColors.Content.secondary)

                        TextField("Enter title", text: $selectedTextTitle)
                            .focused($isSectionTextTitleFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                UIApplication.shared.dismissKeyboard()
                            }
                            .font(MindMoryTypography.bodyMedium)
                            .padding(MindMorySpacing.sm)
                            .background(MindMoryColors.Surface.surface)
                            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                    .stroke(MindMoryColors.Border.subtle)
                            )
                    }

                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        Text("Description")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)

                        TextField("Enter description", text: $selectedTextDescription, axis: .vertical)
                            .focused($isSectionTextDescriptionFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                UIApplication.shared.dismissKeyboard()
                            }
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

                    Spacer()
                }
                .padding(MindMorySpacing.xl)
                .navigationTitle("Edit Text Section")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            UIApplication.shared.dismissKeyboard()
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

}

#Preview("Graduation Album") {
    NavigationStack {
        MemoryAlbumCreationView(
            viewModel: MemoryAlbumCreationViewModel(sampleSections: PreviewData.graduationAlbumSections)
        ) { _ in }
    }
}
