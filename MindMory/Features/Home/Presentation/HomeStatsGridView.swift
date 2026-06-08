import SwiftUI

struct HomeStatsGridView: View {
    let cards: [HomeStatCardModel]
    let selectedStat: SelectedStatCard?
    let selectAction: (SelectedStatCard) -> Void

    private let spacing = MindMorySpacing.sm
    private let defaultHeight: CGFloat = 92
    private let expandedHeight: CGFloat = 200
    private let smallColumnWidth: CGFloat = 104

    var body: some View {
        GeometryReader { proxy in
            let layout = layoutMetrics(for: proxy.size.width)

            ZStack(alignment: .topLeading) {
                ForEach(cards) { card in
                    let frame = frame(for: card, metrics: layout)

                    ExpandableStatCardView(
                        card: card,
                        isSelected: selectedStat == card.stat
                    ) {
                        selectAction(card.stat)
                    }
                    .frame(width: frame.size.width, height: frame.size.height)
                    .position(x: frame.midX, y: frame.midY)
                }
            }
        }
        .frame(height: selectedStat == nil ? defaultHeight : expandedHeight)
        .animation(.easeInOut(duration: 0.35), value: selectedStat)
    }

    private func layoutMetrics(for width: CGFloat) -> StatCardLayoutMetrics {
        if selectedStat == nil {
            let cardWidth = (width - spacing * 2) / 3
            return StatCardLayoutMetrics(
                mode: .default(cardWidth: cardWidth),
                totalWidth: width,
                spacing: spacing,
                defaultHeight: defaultHeight,
                expandedHeight: expandedHeight,
                smallColumnWidth: smallColumnWidth
            )
        }

        return StatCardLayoutMetrics(
            mode: .expanded,
            totalWidth: width,
            spacing: spacing,
            defaultHeight: defaultHeight,
            expandedHeight: expandedHeight,
            smallColumnWidth: smallColumnWidth
        )
    }

    private func frame(
        for card: HomeStatCardModel,
        metrics: StatCardLayoutMetrics
    ) -> CGRect {
        switch metrics.mode {
        case .default(let cardWidth):
            let index = CGFloat(cards.firstIndex(where: { $0.id == card.id }) ?? 0)
            return CGRect(
                x: index * (cardWidth + metrics.spacing),
                y: 0,
                width: cardWidth,
                height: metrics.defaultHeight
            )

        case .expanded:
            guard selectedStat != card.stat else {
                let largeWidth = metrics.totalWidth - metrics.smallColumnWidth - metrics.spacing
                return CGRect(
                    x: metrics.smallColumnWidth + metrics.spacing,
                    y: 0,
                    width: largeWidth,
                    height: metrics.expandedHeight
                )
            }

            let smallCards = cards.filter { $0.stat != selectedStat }
            let smallIndex = CGFloat(smallCards.firstIndex(where: { $0.id == card.id }) ?? 0)
            let smallHeight = (metrics.expandedHeight - metrics.spacing) / 2
            return CGRect(
                x: 0,
                y: smallIndex * (smallHeight + metrics.spacing),
                width: metrics.smallColumnWidth,
                height: smallHeight
            )
        }
    }
}

private struct StatCardLayoutMetrics {
    let mode: StatCardLayoutMode
    let totalWidth: CGFloat
    let spacing: CGFloat
    let defaultHeight: CGFloat
    let expandedHeight: CGFloat
    let smallColumnWidth: CGFloat
}

private enum StatCardLayoutMode {
    case `default`(cardWidth: CGFloat)
    case expanded
}
