import SwiftUI

struct SettingsMessageToneCardView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.md) {
                ForEach(ReminderMessageTone.allCases) { tone in
                    RadioSelectionRow(
                        title: tone.title,
                        subtitle: tone.example,
                        isSelected: viewModel.preferences.message.tone == tone,
                        action: { viewModel.preferences.message.tone = tone }
                    )

                    if tone.id != ReminderMessageTone.allCases.last?.id {
                        Divider().overlay(MindMoryColors.Border.subtle)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SettingsMessageToneCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMessageToneCardView(viewModel: SettingsViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
