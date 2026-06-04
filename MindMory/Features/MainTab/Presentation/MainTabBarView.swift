import SwiftUI

struct MainTabBarView: View {

    @Binding var selectedTab: MainTab

    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, MindMorySpacing.lg)
        .padding(.top, MindMorySpacing.md)
        .padding(.bottom, MindMorySpacing.lg)
        .background(MindMoryColors.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(MindMoryColors.border)
                .frame(height: 1)
        }
    }

    private func tabButton(for tab: MainTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: MindMorySpacing.xxs) {
                Image(systemName: tab.icon)
                Text(tab.title)
                    .font(MindMoryTypography.tabLabel)
            }
            .foregroundStyle(foregroundColor(for: tab))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func foregroundColor(for tab: MainTab) -> Color {
        selectedTab == tab ? MindMoryColors.primaryGreen : MindMoryColors.textSecondary
    }
}
