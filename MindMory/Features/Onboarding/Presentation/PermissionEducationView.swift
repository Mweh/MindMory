import SwiftUI

struct PermissionEducationView: View {
    let enableAction: () -> Void
    let laterAction: () -> Void
    var body: some View {
        VStack(spacing: MindMorySpacing.xl) {
            Spacer()
            IconBadgeView(systemName: "bell.badge.fill")
            Text("Enable smart reminders")
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
            Text("MindMory needs notifications, location, and calendar access to remind you at the right moment.")
                .font(MindMoryTypography.bodyLarge)
                .foregroundStyle(MindMoryColors.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(title: "Enable Smart Reminders", action: enableAction)
            SecondaryButton(title: "Maybe Later", action: laterAction)
        }
    }
}
