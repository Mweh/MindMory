import PhotosUI
import SwiftUI

struct TimelineAlbumCreateView: View {
    enum Step {
        case details
        case selectPhotos
        case review
    }

    @StateObject private var viewModel: TimelineAlbumViewModel
    @State private var selectedCoverPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var currentStep: Step = .details
    let onCreate: (Album) -> Void
    @Environment(\.dismiss) private var dismiss

    init(viewModel: TimelineAlbumViewModel, onCreate: @escaping (Album) -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onCreate = onCreate
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                stepHeader

                switch currentStep {
                case .details:
                    detailsStep
                case .selectPhotos:
                    selectPhotosStep
                case .review:
                    reviewStep
                }

                footerButtons
            }
            .padding(MindMorySpacing.xl)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("Create Timeline Album")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedCoverPhotoItem) { _, newItem in
            Task {
                guard let item = newItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.updateCoverPhoto(from: [data])
                }
            }
        }
        .onChange(of: selectedPhotoItems) { _, newItems in
            Task {
                var selectedData: [Data] = []

                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedData.append(data)
                    }
                }

                viewModel.updateSelectedPhotos(from: selectedData)
            }
        }
        .alert("Timeline Album", isPresented: alertBinding) {
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
                    Text("Album name")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    TextField("Enter album name", text: $viewModel.albumName)
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
            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Select additional photos")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    PhotosPicker(
                        selection: $selectedPhotoItems,
                        maxSelectionCount: 10,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(viewModel.photos.isEmpty ? "Choose photos" : "Update selected photos")
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

                    Text(viewModel.photos.isEmpty ? "Add extra photos for your album." : "Selected photos: \(viewModel.photos.count)")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
            }

            if !viewModel.photos.isEmpty {
                photoPreviewGrid
            }
        }
    }

    private var reviewStep: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Timeline summary")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(viewModel.albumName)
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text("Cover photo selected")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
            }

            if let coverPhoto = viewModel.coverPhoto, let image = coverPhoto.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(MindMoryRadius.large)
            }

            AppCard {
                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text("Extra photos")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(viewModel.photos.isEmpty ? "No additional photos selected." : "\(viewModel.photos.count) additional photo\(viewModel.photos.count == 1 ? "" : "s")")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.textSecondary)
                }
            }

            if !viewModel.photos.isEmpty {
                photoPreviewGrid
            }
        }
    }

    private var photoPreviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: MindMorySpacing.sm) {
            ForEach(viewModel.photos) { photo in
                if let image = photo.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(MindMoryRadius.large)
                }
            }
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
        case .review:
            return "Step 3"
        }
    }

    private var stepSubtitle: String {
        switch currentStep {
        case .details:
            return "Timeline title and cover photo"
        case .selectPhotos:
            return "Choose extra photos"
        case .review:
            return "Confirm and save"
        }
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case .details:
            return "Continue"
        case .selectPhotos:
            return "Review"
        case .review:
            return "Create Album"
        }
    }

    private var primaryButtonDisabled: Bool {
        switch currentStep {
        case .details:
            return viewModel.isSaveButtonDisabled
        case .selectPhotos:
            return false
        case .review:
            return viewModel.isSaveButtonDisabled
        }
    }

    private func primaryButtonAction() {
        switch currentStep {
        case .details:
            currentStep = .selectPhotos
        case .selectPhotos:
            currentStep = .review
        case .review:
            viewModel.saveAlbum()
        }
    }

    private func previousStep() {
        switch currentStep {
        case .details:
            break
        case .selectPhotos:
            currentStep = .details
        case .review:
            currentStep = .selectPhotos
        }
    }
}

#Preview {
    NavigationStack {
        TimelineAlbumCreateView(viewModel: TimelineAlbumViewModel()) { _ in }
    }
}
