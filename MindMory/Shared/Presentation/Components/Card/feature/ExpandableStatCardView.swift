import SwiftUI

struct ExpandableStatCardView: View {
    let card: HomeStatCardModel
    let isSelected: Bool

    var body: some View {
        ZStack {
            cardBackground

            compactContent
                .padding(MindMorySpacing.sm)
        }
        .clipShape(cardShape)
        .overlay {
            cardShape.stroke(MindMoryColors.Content.inverse.opacity(0.08), lineWidth: 1)
        }
        .shadow(
            color: MindMoryColors.Surface.primary.opacity(0.14),
            radius: 10,
            x: 0,
            y: 7
        )
    }

    private var compactContent: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(card.title)
                .font(MindMoryTypography.titleSmall)
                .foregroundStyle(MindMoryColors.Content.inverse.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(card.primaryValue)
                .font(MindMoryTypography.titleLarge)
                .foregroundStyle(MindMoryColors.Content.inverse.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Text(card.secondaryValue)
                .font(MindMoryTypography.labelSmall)
                .foregroundStyle(MindMoryColors.Content.inverse.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [MindMoryColors.Surface.primary, MindMoryColors.Surface.primary, MindMoryColors.Surface.primary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }
}

#if DEBUG
struct ExpandableStatCardView_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableStatCardView(card: HomeStatCardModel(stat: .captured, title: "Stats", primaryValue: "42", secondaryValue: "units", monthlyDetail: "12", yearlyDetail: "20"), isSelected: false)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

#Preview {
    ExpandableStatCardView(card: HomeStatCardModel(stat: .captured, title: "Stats", primaryValue: "42", secondaryValue: "units", monthlyDetail: "12", yearlyDetail: "20"), isSelected: false)
        .frame(width: 300, height: 92)
        .padding()
        .background(MindMoryColors.Surface.background)
}
