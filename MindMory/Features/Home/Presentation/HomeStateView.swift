import SwiftUI

struct HomeStateView: View {

    let state: HomeViewState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                contentView
            }
            .padding(MindMorySpacing.xl)
        }
        .background(MindMoryColors.background.ignoresSafeArea())
    }

    @ViewBuilder
    private var contentView: some View {
        switch state {
        case .loading:
            LoadingStateView()
                .frame(maxWidth: .infinity, minHeight: 500)

        case .positive(let reminder, let memory):
            positiveStateView(reminder: reminder, memory: memory)

        case .empty:
            EmptyStateView(
                title: "Your first reminder is being prepared.",
                message: "We're learning the moments that matter to you so we can remind you at the right time"
            )
            .frame(maxWidth: .infinity, minHeight: 500)

        case .permissionRequired:
            permissionStateView

        case .error(let message):
            ErrorStateView(message: message)
        }
    }

    private func positiveStateView(reminder: Reminder, memory: Memory?) -> some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
            headerSection

            HomeReminderCardView(reminder: reminder)

            if let memory {
                HomeMemoryFrameView(memory: memory)
                journalPromptSection
                actionRowSection
            }

            WidgetPreviewCardView()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text("Good evening ✨")
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(MindMoryColors.textSecondary)

            Text("Here’s your moment\nto remember.")
                .font(MindMoryTypography.displayLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
        }
    }

    private var journalPromptSection: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                Text("Today’s Reflection")
                    .font(MindMoryTypography.caption)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text("What made today memorable?")
                    .font(MindMoryTypography.bodyMedium)

                Text("Jot down a few words...")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }
        }
    }

    private var actionRowSection: some View {
        HStack {
            Label("Share", systemImage: "square.and.arrow.up")

            Spacer()

            Label("Favorite", systemImage: "star")
        }
        .font(MindMoryTypography.bodySmall)
        .foregroundStyle(MindMoryColors.primaryGreen)
        .padding(.horizontal, 16)
    }

    private var permissionStateView: some View {
        VStack(spacing: MindMorySpacing.md) {
            EmptyStateView(
                title: "Smart reminders need access",
                message: "MindMory needs notifications, location, and calendar access "
                    + "to remind you at the right moment."
            )

            PrimaryButton(title: "Enable Smart Reminders", action: {})
            SecondaryButton(title: "Maybe Later", action: {})
        }
    }
}

#Preview("Positive State") {
    HomeStateView(state: .positive(PreviewData.reminder, PreviewData.aromaMemory))
}

#Preview("Loading State") {
    HomeStateView(state: .loading)
}

#Preview("Empty State") {
    HomeStateView(state: .empty)
}

#Preview("Permission Required") {
    HomeStateView(state: .permissionRequired)
}

#Preview("Error State") {
    HomeStateView(state: .error("Something went wrong. Please try again."))
}
