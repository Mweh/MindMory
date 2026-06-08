import SwiftUI

struct HomeStatsGridView: View {
    let cards: [HomeStatCardModel]
    let selectedStat: SelectedHomeStat
    let selectAction: (SelectedHomeStat) -> Void

    var body: some View {
        VStack(spacing: MindMorySpacing.sm) {
            if let selectedCard {
                ExpandableStatCardView(card: selectedCard, isSelected: true) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                        selectAction(selectedCard.stat)
                    }
                }
            }

            HStack(spacing: MindMorySpacing.sm) {
                ForEach(collapsedCards) { card in
                    ExpandableStatCardView(card: card, isSelected: false) {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.82)) {
                            selectAction(card.stat)
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: selectedStat)
    }

    private var selectedCard: HomeStatCardModel? {
        cards.first { $0.stat == selectedStat }
    }

    private var collapsedCards: [HomeStatCardModel] {
        cards.filter { $0.stat != selectedStat }
    }
}
