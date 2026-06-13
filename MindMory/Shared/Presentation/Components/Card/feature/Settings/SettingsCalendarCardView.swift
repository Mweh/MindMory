import SwiftUI

struct SettingsCalendarCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                HStack(alignment: .center, spacing: MindMorySpacing.sm) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xxs) {
                        Text("Schedule reminder")
                            .font(MindMoryTypography.titleMedium)
                            .foregroundStyle(MindMoryColors.Content.primary)

                        Text("Receive photo reminders around the events that matter to you.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.secondary)
                    }

                    Spacer()

                    Toggle(isOn: $viewModel.preferences.schedule.usesCalendarContext) {
                        EmptyView()
                    }
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: MindMoryColors.Surface.primary))
                }

                Divider().overlay(MindMoryColors.Border.subtle)

                if viewModel.preferences.schedule.usesCalendarContext {
                    SettingsNavigationRow(
                        title: "Select event reminders",
                        subtitle: "Help MindMory focus on the events that matter most to you.",
                        summary: viewModel.preferences.scheduleSummary,
                        iconName: "calendar.badge.clock",
                        destination: { ScheduleSettingsDetailView(viewModel: viewModel) }
                    )
                } else {
                    HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                        ZStack {
                            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                .fill(MindMoryColors.Surface.elevated)
                                .frame(width: 42, height: 42)

                            Image(systemName: "bell.slash.fill")
                                .font(MindMoryTypography.labelSmall)
                                .foregroundStyle(MindMoryColors.Content.secondary)
                        }

                        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                            Text("Calendar reminders are off")
                                .font(MindMoryTypography.bodyLarge)
                                .foregroundStyle(MindMoryColors.Content.primary)

                            Text("The app will not deliver any calendar-based reminders until this is turned on.")
                                .font(MindMoryTypography.bodySmall)
                                .foregroundStyle(MindMoryColors.Content.secondary)
                        }

                        Spacer()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsCalendarCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCalendarCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
