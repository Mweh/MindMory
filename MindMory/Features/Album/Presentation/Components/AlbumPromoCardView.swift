import SwiftUI

struct AlbumPromoCardView: View {

    let totalAlbums: Int
    let onAdd: () -> Void

    init(totalAlbums: Int = 0, onAdd: @escaping () -> Void = {}) {
        self.totalAlbums = totalAlbums
        self.onAdd = onAdd
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .fill(cardBackgroundColor)

            HStack(alignment: .top, spacing: MindMorySpacing.lg) {
                SectionTitle(
                    title: "\(totalAlbums)",
                    description: "Your total album",
                    size: .medium,
                    titleColor: titleColor,
                    descriptionColor: subtitleColor
                )

                Spacer()
            }
            .padding(.vertical, MindMorySpacing.md)
            .padding(.horizontal, MindMorySpacing.lg)

            promoBadge
                .offset(x: 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
        )
        .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }

    private var promoBadge: some View {
        Button(action: onAdd) {
            ZStack {
                Circle()
                    .fill(promoBadgeFillColor)
                    .frame(width: 88, height: 88)

                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(promoBadgeTextColor)
            }
            .frame(width: 88, height: 88)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add album")
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
