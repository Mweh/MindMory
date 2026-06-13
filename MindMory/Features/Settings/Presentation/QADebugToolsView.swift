import PhotosUI
import SwiftUI

struct QADebugToolsView: View {

    @StateObject var viewModel: QADebugToolsViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        Form {
            Section {
                Toggle("Skip Onboarding", isOn: $viewModel.skipOnboarding)

                Button("Reset Onboarding", role: .destructive) {
                    viewModel.resetOnboarding()
                }
            } header: {
                Text("Onboarding")
            } footer: {
                Text("Debug/testing only. Resetting onboarding lets QA verify the first-run flow again.")
            }

            Section {
                HomeCardStatePickerView(selectedState: $viewModel.homeCardState)
            } header: {
                Text("Home Card State")
            } footer: {
                Text("Controls which large Home card is shown for QA testing.")
            }

            Section {
                currentImagePreview

                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Import Photo", systemImage: "photo.badge.plus")
                }

                Button("Reset to Default Photo", role: .destructive) {
                    viewModel.resetHomeCardPhoto()
                }
            } header: {
                Text("Home 3D Card Mock Photo")
            } footer: {
                Text("The selected photo is stored locally and overrides the Home 3D card image in Debug builds.")
            }

            if let statusMessage = viewModel.statusMessage {
                Section {
                    Text(statusMessage)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }
            }
        }
        .navigationTitle("QA Debug Tools")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task { await viewModel.importPhoto(from: newItem) }
        }
    }

    private var currentImagePreview: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Current image preview")
                .font(MindMoryTypography.bodyMedium)

            MemoryImagePlaceholderView(
                imageName: PreviewData.aromaMemory.imageName,
                debugImageURL: viewModel.selectedImageURL
            )
            .frame(height: 180)
            .clipShape(
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
            )
        }
        .padding(.vertical, MindMorySpacing.xs)
    }
}

#Preview {
    NavigationStack {
        QADebugToolsView(
            viewModel: QADebugToolsViewModel(
                repository: QADebugSettingsRepository(),
                imageStorageService: DebugImageStorageService()
            )
        )
    }
}
