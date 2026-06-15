import SwiftUI

struct ContextualTriggersView: View {

    @ObservedObject var viewModel: ContextualTriggersViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            SectionTitle(
                title: "Contextual triggers",
                description: "Turn on which kinds of location and moment triggers should create reminders.",
                size: .medium
            )

            SettingsNotificationTriggersCard(viewModel: viewModel)
        }
    }
}
