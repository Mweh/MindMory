import SwiftUI

struct SettingsScheduleFilterCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack {
                    Text(selectedScheduleCountText)
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Spacer()

                    if !viewModel.preferences.schedule.selectedCategories.isEmpty {
                        SettingsSecondaryPillButton(
                            title: "Clear",
                            action: viewModel.clearScheduleCategories
                        )
                    }
                }

                Divider().overlay(MindMoryColors.Border.subtle)

                ForEach(CalendarContextCategory.allCases) { category in
                    SettingsSelectableRow(
                        title: category.title,
                        subtitle: category.description,
                        isSelected: viewModel.preferences.schedule.selectedCategories.contains(category),
                        action: { viewModel.toggleScheduleCategory(category) }
                    )

                    if category.id != CalendarContextCategory.allCases.last?.id {
                        Divider().overlay(MindMoryColors.Border.subtle)
                    }
                }

                if viewModel.preferences.schedule.selectedCategories.isEmpty {
                    Text("Select at least one calendar trigger if you want schedule reminders to stay active.")
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.Feedback.error)
                }

                Divider().overlay(MindMoryColors.Border.subtle)
            }
        }
    }

    private var selectedScheduleCountText: String {
        let count = viewModel.preferences.schedule.selectedCategories.count
        let label = count == 1 ? "calendar event selected" : "calendar events selected"
        return "\(count) \(label)"
    }
}

#if DEBUG
struct SettingsScheduleFilterCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScheduleFilterCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
