import SwiftUI

struct HomeStatsGridView: View {
    let cards: [HomeStatCardModel]
    let selectedStat: SelectedStatCard?
    let selectAction: (SelectedStatCard) -> Void

    var body: some View {
        Group {
            if let selectedStat,
               let selectedCard = card(for: selectedStat) {
                expandedLayout(selectedCard: selectedCard)
            } else {
                defaultLayout
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: selectedStat)
    }

    private var defaultLayout: some View {
        HStack(spacing: MindMorySpacing.sm) {
            ForEach(cards) { card in
                ExpandableStatCardView(card: card, isSelected: false) {
                    selectAction(card.stat)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 92)
            }
        }
    }

    private func expandedLayout(selectedCard: HomeStatCardModel) -> some View {
        HStack(alignment: .top, spacing: MindMorySpacing.md) {
            VStack(spacing: MindMorySpacing.sm) {
                ForEach(cards.filter { $0.stat != selectedCard.stat }) { card in
                    ExpandableStatCardView(card: card, isSelected: false) {
                        selectAction(card.stat)
                    }
                    .frame(height: 96)
                }
            }
            .frame(width: 104)

            ExpandableStatCardView(card: selectedCard, isSelected: true) {
                selectAction(selectedCard.stat)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        }
    }

    private func card(for stat: SelectedStatCard) -> HomeStatCardModel? {
        cards.first { $0.stat == stat }
    }
}
