import SwiftUI

struct HomeStateView: View {
    let state: HomeViewState
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                switch state {
                case .loading: LoadingStateView().frame(maxWidth:.infinity, minHeight: 500)
                case .positive(let reminder, let memory): positive(reminder: reminder, memory: memory)
                case .empty: EmptyStateView(title: "No reminder right now.", message: "We’ll nudge you when a moment feels worth keeping.")
                case .permissionRequired: permissionState
                case .error(let message): ErrorStateView(message: message)
                }
            }.padding(MindMorySpacing.xl)
        }.background(MindMoryColors.background.ignoresSafeArea())
    }
    private func positive(reminder: Reminder, memory: Memory?) -> some View {
        VStack(alignment:.leading, spacing: MindMorySpacing.lg) {
            Text("Good evening ✨").font(MindMoryTypography.bodySmall).foregroundStyle(MindMoryColors.textSecondary)
            Text("Here’s your moment\nto remember.").font(MindMoryTypography.displayLarge).foregroundStyle(MindMoryColors.textPrimary)
            HomeReminderCardView(reminder: reminder)
            if let memory { HomeMemoryFrameView(memory: memory); journalPrompt; actionRow }
            WidgetPreviewCardView()
        }
    }
    private var journalPrompt: some View { AppCard { VStack(alignment:.leading){ Text("Today’s Reflection").font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.textPrimary); Text("What made today memorable?").font(MindMoryTypography.bodyMedium); Text("Jot down a few words...").font(MindMoryTypography.bodySmall).foregroundStyle(MindMoryColors.textSecondary) } } }
    private var actionRow: some View { HStack { Label("Share", systemImage:"square.and.arrow.up"); Spacer(); Label("Favorite", systemImage:"star"); Spacer(); Label("View in Album", systemImage:"photo.on.rectangle") }.font(MindMoryTypography.bodySmall).foregroundStyle(MindMoryColors.primaryGreen) }
    private var permissionState: some View { VStack(spacing:MindMorySpacing.md){ EmptyStateView(title:"Smart reminders need access", message:"MindMory needs notifications, location, and calendar access to remind you at the right moment."); PrimaryButton(title:"Enable Smart Reminders", action:{}); SecondaryButton(title:"Maybe Later", action:{}) } }
}
