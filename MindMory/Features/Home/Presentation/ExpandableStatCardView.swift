import SwiftUI

struct ExpandableStatCardView: View {
    let card: HomeStatCardModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text(card.title)
                    .font(MindMoryTypography.caption)
                    .foregroundStyle(Color.white.opacity(0.72))
                    .textCase(.uppercase)
                    .tracking(1.2)

                Spacer(minLength: MindMorySpacing.xs)

                Text(card.primaryValue)
                    .font(isSelected ? MindMoryTypography.displayLarge : MindMoryTypography.headingLarge)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(card.secondaryValue)
                    .font(isSelected ? MindMoryTypography.headingMedium : MindMoryTypography.bodyMedium)
                    .foregroundStyle(Color.white.opacity(0.82))
                    .lineLimit(isSelected ? 2 : 1)
                    .minimumScaleFactor(0.75)

                if isSelected {
                    HStack(spacing: MindMorySpacing.sm) {
                        detailPill(card.monthlyDetail)
                        detailPill(card.yearlyDetail)
                    }
                    .padding(.top, MindMorySpacing.xs)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(isSelected ? MindMorySpacing.lg : MindMorySpacing.md)
            .frame(maxWidth: .infinity, minHeight: isSelected ? 180 : 118, alignment: .topLeading)
            .background(cardBackground)
            .clipShape(cardShape)
            .overlay {
                cardShape.stroke(Color.white.opacity(isSelected ? 0.18 : 0.09), lineWidth: 1)
            }
            .shadow(color: MindMoryColors.deepGreen.opacity(isSelected ? 0.28 : 0.16), radius: isSelected ? 22 : 12, x: 0, y: isSelected ? 16 : 8)
            .scaleEffect(isSelected ? 1 : 0.96)
        }
        .buttonStyle(.plain)
    }

    private func detailPill(_ text: String) -> some View {
        Text(text)
            .font(MindMoryTypography.caption)
            .foregroundStyle(Color.white.opacity(0.86))
            .padding(.horizontal, MindMorySpacing.sm)
            .padding(.vertical, MindMorySpacing.xs)
            .background(Color.white.opacity(0.12))
            .clipShape(Capsule(style: .continuous))
    }

    private var cardBackground: some View {
        LinearGradient(colors: [MindMoryColors.deepGreen, MindMoryColors.primaryGreen, Color(hex: "#2F7055")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
    }
}
