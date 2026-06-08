import SwiftUI

struct ExpandableStatCardView: View {
    let card: HomeStatCardModel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        GeometryReader { proxy in
            Button(action: action) {
                ZStack {
                    cardBackground

                    Group {
                        if isSelected {
                            expandedContent
                                .padding(MindMorySpacing.md)
                        } else {
                            compactContent
                                .padding(MindMorySpacing.sm)
                        }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipShape(cardShape)
                .overlay {
                    cardShape.stroke(Color.white.opacity(isSelected ? 0.16 : 0.08), lineWidth: 1)
                }
                .shadow(
                    color: MindMoryColors.deepGreen.opacity(isSelected ? 0.24 : 0.14),
                    radius: isSelected ? 20 : 10,
                    x: 0,
                    y: isSelected ? 14 : 7
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var compactContent: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(card.title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(card.primaryValue)
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(Color.white.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Text(card.secondaryValue)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var expandedContent: some View {
        if card.stat == .visited {
            visitedExpandedContent
        } else {
            standardExpandedContent
        }
    }

    private var standardExpandedContent: some View {
        VStack(spacing: 6) {
            Text(card.title)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.96))

            Text(expandedPrimaryValue)
                .font(.system(size: 62, weight: .regular, design: .serif))
                .foregroundStyle(Color.white.opacity(0.96))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(card.secondaryValue)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))

            HStack(spacing: MindMorySpacing.xl) {
                detailColumn(number: "12", label: "This Month")
                detailColumn(number: "20", label: "This Year")
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
    }

    private var visitedExpandedContent: some View {
        VStack(spacing: MindMorySpacing.lg) {
            Text("Visited Places")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.96))

            HStack(spacing: MindMorySpacing.xs) {
                Image(systemName: "location.north.fill")
                Text("Academy")
                    .fontWeight(.bold)
            }
            .font(.system(size: 24, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.96))
            .padding(.horizontal, MindMorySpacing.lg)
            .padding(.vertical, MindMorySpacing.xs)
            .background(Color.white.opacity(0.32))
            .clipShape(Capsule(style: .continuous))

            Text("2 times")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.96))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var expandedPrimaryValue: String {
        switch card.stat {
        case .captured:
            return "22"
        case .visited:
            return card.primaryValue
        case .reminder:
            return "5"
        }
    }

    private func detailColumn(number: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(number)
                .font(.system(size: 30, weight: .regular, design: .rounded))
            Text(label)
                .font(.system(size: 12, weight: .regular, design: .rounded))
        }
        .foregroundStyle(Color.white.opacity(0.92))
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [MindMoryColors.deepGreen, MindMoryColors.primaryGreen, Color(hex: "#235B43")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
    }
}
