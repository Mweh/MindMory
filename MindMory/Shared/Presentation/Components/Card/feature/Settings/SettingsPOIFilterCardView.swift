import SwiftUI

struct SettingsPOIFilterCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    private let columns = [
        GridItem(.flexible(), spacing: MindMorySpacing.sm),
        GridItem(.flexible(), spacing: MindMorySpacing.sm),
        GridItem(.flexible(), spacing: MindMorySpacing.sm)
    ]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(spacing: MindMorySpacing.sm) {
                    Text(selectedCategoryCountText)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Spacer()

                    SettingsSecondaryPillButton(
                        title: "Select all",
                        action: viewModel.selectAllLocationCategories
                    )

                    if !viewModel.preferences.location.selectedCategories.isEmpty {
                        SettingsSecondaryPillButton(
                            title: "Clear",
                            action: viewModel.clearLocationCategories
                        )
                    }
                }

                Divider().overlay(MindMoryColors.Border.subtle)

                LazyVGrid(columns: columns, spacing: MindMorySpacing.sm) {
                    ForEach(PointOfInterestCategory.allCases) { category in
                        SettingsSelectableTile(
                            title: category.title,
                            isSelected: viewModel.preferences.location.selectedCategories.contains(category),
                            action: { viewModel.toggleLocationCategory(category) }
                        )
                    }
                }

                if viewModel.preferences.location.selectedCategories.isEmpty {
                    Text("Select at least one category to keep location-based reminders active.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Feedback.error)
                }

                Divider().overlay(MindMoryColors.Border.subtle)
            }
        }
    }

    private var selectedCategoryCountText: String {
        let count = viewModel.preferences.location.selectedCategories.count
        let label = count == 1 ? "point of interest selected" : "points of interest selected"
        return "\(count) \(label)"
    }
}

#if DEBUG
struct SettingsPOIFilterCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPOIFilterCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
