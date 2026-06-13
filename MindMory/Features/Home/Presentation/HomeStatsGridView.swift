import SwiftUI

struct HomeStatsGridView: View {
    let cards: [HomeStatCardModel]
    let selectedStat: SelectedStatCard?
    let selectAction: (SelectedStatCard) -> Void

    private let spacing = MindMorySpacing.sm
    private let cardHeight: CGFloat = 92

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(cards) { card in
                ExpandableStatCardView(
                    card: card,
                    isSelected: false
                )
                .frame(maxWidth: .infinity)
                .frame(height: cardHeight)
            }
        }
    }
}
