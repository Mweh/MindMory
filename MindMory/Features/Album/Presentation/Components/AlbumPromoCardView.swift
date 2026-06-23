import SwiftUI

struct AlbumPromoCardView: View {

    let totalAlbums: Int
    let onAdd: () -> Void
    @State private var cardHeight: CGFloat = 56

    init(totalAlbums: Int = 0, onAdd: @escaping () -> Void = {}) {
        self.totalAlbums = totalAlbums
        self.onAdd = onAdd
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                    Text("\(totalAlbums)")
                        .font(MindMoryTypography.displayLevel)
                        .foregroundStyle(titleColor)

                    Text("Total albums")
                        .font(MindMoryTypography.bodyMedium)
                        .foregroundStyle(subtitleColor)
                }
                .padding(.vertical, MindMorySpacing.md)
                .padding(.leading, MindMorySpacing.lg)
                .padding(.trailing, badgeSize * 0.75 + MindMorySpacing.lg)

                Spacer()
            }

            promoBadge
                .frame(width: badgeSize, height: badgeSize)
                .offset(x: badgeSize * 0.25)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .fill(cardBackgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: CardHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(CardHeightKey.self) { height in
            if height > 0 {
                cardHeight = height
            }
        }
    }

    private var promoBadge: some View {
        Button(action: onAdd) {
            Circle()
                .fill(promoBadgeFillColor)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(promoBadgeTextColor)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add album")
    }

    private var badgeSize: CGFloat {
        max(cardHeight, 56)
    }

    private var badgeOffset: CGFloat {
        badgeSize / 2
    }

    private struct CardHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 56
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    private var cardBackgroundColor: Color {
        MindMoryColors.Surface.elevated
    }

    private var titleColor: Color {
        totalAlbums > 0 ? MindMoryColors.Content.primary : MindMoryColors.Content.secondary
    }

    private var subtitleColor: Color {
        totalAlbums > 0 ? MindMoryColors.Content.secondary : MindMoryColors.Content.disabled
    }

    private var promoBadgeFillColor: Color {
        totalAlbums > 0 ? MindMoryColors.Surface.primary : MindMoryColors.Surface.disabled
    }

    private var promoBadgeTextColor: Color {
        totalAlbums > 0 ? MindMoryColors.Content.inverse : MindMoryColors.Content.secondary
    }
}

#if DEBUG
struct AlbumPromoCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumPromoCardView()
            .padding()
            .previewLayout(.sizeThatFits)
            .background(MindMoryColors.Surface.background)
    }
}
#endif
