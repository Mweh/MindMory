import PhotosUI
import SwiftUI

struct QADebugToolsView: View {

    @StateObject var viewModel: QADebugToolsViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        PageLayout {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                SectionTitle(
                    title: "QA Debug Tools",
                    description: "Use this debug view to verify onboarding, force specific Home card states, and override the Home card image during testing.",
                    size: .large
                )

                onboardingSection
                homeCardStateSection
                photoOverrideSection

                if let statusMessage = viewModel.statusMessage {
                    statusSection(message: statusMessage)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("QA Debug Tools")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task { await viewModel.importPhoto(from: newItem) }
        }
    }

    private var onboardingSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                SectionTitle(
                    title: "Onboarding",
                    description: "Reset or re-enable the first-run flow so QA can verify onboarding screens again.",
                    size: .medium
                )

                Toggle(isOn: $viewModel.skipOnboarding) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Skip onboarding")
                            .font(MindMoryTypography.bodyLarge)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text("The app will treat onboarding as completed until this is reset.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))

                Divider().overlay(MindMoryColors.Border.subtle)

                Button("Reset onboarding", role: .destructive) {
                    viewModel.resetOnboarding()
                }
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.Content.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MindMorySpacing.md)
                .background(MindMoryColors.Surface.surface)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            }
        }
    }

    private var homeCardStateSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                SectionTitle(
                    title: "Home card state",
                    description: "Force a specific Home card scenario for QA playback and UI verification.",
                    size: .medium
                )

                Text("The selected state will be reflected in the Home screen after return.")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

                HomeCardStatePickerView(selectedState: $viewModel.homeCardState)
                    .padding(.top, MindMorySpacing.sm)
            }
        }
    }

    private var photoOverrideSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                SectionTitle(
                    title: "Home card photo override",
                    description: "Import an image to override the Home card photo during debug testing.",
                    size: .medium
                )

                ImagePlaceholder(
                    imageName: PreviewData.aromaMemory.imageName,
                    title: nil,
                    subtitle: "No override photo selected yet."
                )
                .frame(height: 180)

                HStack(spacing: MindMorySpacing.sm) {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        HStack(spacing: MindMorySpacing.sm) {
                            Image(systemName: "photo.badge.plus")
                                .font(MindMoryTypography.bodyLarge)

                            Text("Import photo")
                                .font(MindMoryTypography.bodyLarge)
                        }
                        .foregroundStyle(MindMoryColors.Surface.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MindMorySpacing.md)
                        .background(MindMoryColors.Surface.surface)
                        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button("Reset to default", role: .destructive) {
                        viewModel.resetHomeCardPhoto()
                    }
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .padding(.vertical, MindMorySpacing.md)
                    .padding(.horizontal, MindMorySpacing.lg)
                    .background(MindMoryColors.Surface.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func statusSection(message: String) -> some View {
        AppCard {
            HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                Image(systemName: "info.circle")
                    .font(MindMoryTypography.titleSmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

                Text(message)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
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
