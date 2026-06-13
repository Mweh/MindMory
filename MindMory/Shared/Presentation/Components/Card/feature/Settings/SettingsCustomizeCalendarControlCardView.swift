import SwiftUI

struct SettingsCustomizeCalendarControlCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                SettingsMenuPicker(
                    title: "Reminder timing",
                    selectionTitle: viewModel.preferences.schedule.leadTime.title
                ) {
                    Picker("Reminder timing", selection: $viewModel.preferences.schedule.leadTime) {
                        ForEach(ScheduleLeadTime.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                }

                Toggle("Include all-day events", isOn: $viewModel.preferences.schedule.includesAllDayEvents)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))

                Toggle("Include busy calendar blocks", isOn: $viewModel.preferences.schedule.includesBusyCalendarBlocks)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))

                Toggle("Mention the event title", isOn: $viewModel.preferences.message.includesEventTitle)
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
            }
            .disabled(!viewModel.preferences.schedule.usesCalendarContext)
            .opacity(viewModel.preferences.schedule.usesCalendarContext ? 1 : 0.6)
        }
    }
}

#if DEBUG
struct SettingsCustomizeCalendarControlCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCustomizeCalendarControlCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
