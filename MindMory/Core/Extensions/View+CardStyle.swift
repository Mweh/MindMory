import SwiftUI

extension View {
    func mindMoryCardStyle(radius: CGFloat = MindMoryRadius.medium) -> some View {
        let cardShape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return self
            .background(cardShape.fill(MindMoryColors.Surface.surface))
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }
}
