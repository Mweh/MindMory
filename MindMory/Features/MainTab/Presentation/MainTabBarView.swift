import SwiftUI

struct MainTabBarView: View {
    @Binding var selectedTab: MainTab
    var body: some View {
        HStack { ForEach(MainTab.allCases, id: \.self) { tab in Button { selectedTab = tab } label: { VStack(spacing: MindMorySpacing.xxs) { Image(systemName: tab.icon); Text(tab.title).font(MindMoryTypography.tabLabel) }.foregroundStyle(selectedTab == tab ? MindMoryColors.primaryGreen : MindMoryColors.textSecondary).frame(maxWidth: .infinity) }.buttonStyle(.plain) } }
        .padding(.horizontal, MindMorySpacing.lg).padding(.top, MindMorySpacing.md).padding(.bottom, MindMorySpacing.lg)
        .background(MindMoryColors.background)
        .overlay(alignment:.top){ Rectangle().fill(MindMoryColors.border).frame(height:1) }
    }
}
