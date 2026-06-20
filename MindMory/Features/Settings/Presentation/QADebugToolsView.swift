import SwiftUI

struct QADebugToolsView: View {

    @StateObject var viewModel: QADebugToolsViewModel

    var body: some View {
        PageLayout {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                SectionTitle(
                    title: "Onboarding",
                    description: "Reset or re-enable the first-run flow so QA can verify onboarding screens again.",
                    size: .medium
                )

                onboardingSection

                SectionTitle(
                    title: "Home debugging",
                    description: "Force specific Home states and permission flows when QA Debug Mode is enabled.",
                    size: .medium
                )

                qaHomeStateSection

                if let statusMessage = viewModel.statusMessage {
                    statusSection(message: statusMessage)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("QA Debug Tools")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var onboardingSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
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

    private var recentImageOptions: [QADebugHomeState] {
        [.loadedOne, .loadedTwo, .loadedThree, .empty, .error]
    }

    private var favoriteImageOptions: [QADebugHomeState] {
        [.loadedFavorite, .empty, .error]
    }

    private var photoLibraryPermissionOptions: [QADebugHomeState] {
        [.permissionGrantedPhotoLibrary, .permissionRequiredPhotoLibrary, .permissionDeniedPhotoLibrary]
    }

    private var locationPermissionOptions: [QADebugHomeState] {
        [.permissionGrantedLocation, .permissionRequiredLocation, .permissionDeniedLocation]
    }

    private var qaHomeStateSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            photoLibraryPermissionCard
            locationPermissionCard
            homeStateCard
        }
    }

    private var isBlockingPermissionOverrideActive: Bool {
        viewModel.selectedLocationPermissionState.isBlocking ||
        viewModel.selectedPhotoLibraryPermissionState.isBlocking
    }

    private var homeStateCard: some View {
        AppCard {
            if isBlockingPermissionOverrideActive {
                permissionOverrideNotice
            } else {
                recentImageSection
                favoriteImageSection
            }
        }
    }

    private var permissionOverrideNotice: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "QA home state blocked",
                description: "A permission override is active, so the Home debug state will not be applied.",
                size: .small
            )

            Text("Clear the current permission override to enable Home state selection.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: clearPermissionOverrides) {
                Text("Clear permission override")
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Surface.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MindMorySpacing.sm)
                    .background(MindMoryColors.Surface.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, MindMorySpacing.md)
    }

    private func clearPermissionOverrides() {
        viewModel.clearBlockingPermissionOverrides()
    }

    private var permissionDeniedNotice: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Recent image state",
                description: "Recent image and favorite state controls are disabled while a permission is denied.",
                size: .small
            )

            Text("Enable both location and photo library permissions before changing the recent/favorite debug states.")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.Content.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, MindMorySpacing.md)
    }

    private var photoLibraryPermissionCard: some View {
        AppCard {
            photoLibraryPermissionSection
        }
    }

    private var locationPermissionCard: some View {
        AppCard {
            locationPermissionSection
        }
    }

    private var recentImageSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Recent image state",
                description: "Force the recent photo section to show one, two, or three debug placeholders.",
                size: .small
            )

            VStack(spacing: MindMorySpacing.sm) {
                ForEach(recentImageOptions) { state in
                    RadioSelectionRow(
                        title: state.title,
                        subtitle: state.description,
                        isSelected: viewModel.selectedRecentState == state,
                        action: { viewModel.selectedRecentState = state }
                    )
                }
            }
        }
    }

    private var favoriteImageSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Favorite image state",
                description: "Force the Home card to display a favorite debug memory or a QA empty/error state.",
                size: .small
            )

            VStack(spacing: MindMorySpacing.sm) {
                ForEach(favoriteImageOptions) { state in
                    RadioSelectionRow(
                        title: state.title,
                        subtitle: state.description,
                        isSelected: viewModel.selectedHomeState == state,
                        action: { viewModel.selectedHomeState = state }
                    )
                }
            }
        }
    }

    private var photoLibraryPermissionSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Photo library permission",
                description: "Debug the Home flow when access to the photo library is required.",
                size: .small
            )

            VStack(spacing: MindMorySpacing.sm) {
                ForEach(photoLibraryPermissionOptions) { state in
                    RadioSelectionRow(
                        title: state.title,
                        subtitle: state.description,
                        isSelected: viewModel.selectedPhotoLibraryPermissionState == state,
                        action: { viewModel.selectedPhotoLibraryPermissionState = state }
                    )
                }
            }
        }
    }

    private var locationPermissionSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Location permission",
                description: "Debug the Home flow when location permission is missing or denied.",
                size: .small
            )

            VStack(spacing: MindMorySpacing.sm) {
                ForEach(locationPermissionOptions) { state in
                    RadioSelectionRow(
                        title: state.title,
                        subtitle: state.description,
                        isSelected: viewModel.selectedLocationPermissionState == state,
                        action: { viewModel.selectedLocationPermissionState = state }
                    )
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
                repository: QADebugSettingsRepository()
            )
        )
    }
}
