import SwiftUI

struct SettingsView: View { @StateObject var viewModel: SettingsViewModel; @StateObject var triggersViewModel: ContextualTriggersViewModel
    var body: some View { NavigationStack { ScrollView { VStack(alignment:.leading, spacing:MindMorySpacing.lg){ Text("Settings").font(MindMoryTypography.displayLarge); Text("Shape how MindMory understands context, words reminders gently, and protects your privacy.").font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.textSecondary); AppCard { VStack(alignment:.leading, spacing:MindMorySpacing.md){ Text("Permission Education").font(MindMoryTypography.headingMedium); ForEach(viewModel.permissionRows){ row in HStack{ VStack(alignment:.leading){ Text(row.title).font(MindMoryTypography.bodyMedium); Text(row.description).font(MindMoryTypography.bodySmall).foregroundStyle(MindMoryColors.textSecondary) }; Spacer(); Text(label(for: row.status)).font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.primaryGreen) } }; PrimaryButton(title:"Enable Smart Reminders", action:viewModel.requestAll) } }; ContextualTriggersView(viewModel: triggersViewModel); WidgetPreviewCardView(); AppCard { VStack(alignment:.leading, spacing:MindMorySpacing.sm){ Text("Privacy").font(MindMoryTypography.headingMedium); Text("Context helps MindMory decide when a reminder feels useful. This foundation uses mock data while the team defines production privacy rules.").font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.textSecondary) } } }.padding(MindMorySpacing.xl) }.background(MindMoryColors.background.ignoresSafeArea()) } }
    private func label(for status: PermissionStatus) -> String {
        switch status {
        case .notDetermined: return "Not set"
        case .granted: return "Enabled"
        case .denied: return "Needs review"
        }
    }
}
#Preview { SettingsView(viewModel: DependencyContainer().makeSettingsViewModel(), triggersViewModel: DependencyContainer().makeContextualTriggersViewModel()) }
