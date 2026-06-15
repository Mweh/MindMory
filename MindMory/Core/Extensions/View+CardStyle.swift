import SwiftUI

extension View {
    func mindMoryCardStyle(radius: CGFloat = MindMoryRadius.medium) -> some View {
        self
            .background(MindMoryColors.Surface.background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
            .shadow(color: MindMoryShadow.cardColor, radius: MindMoryShadow.softRadius, x: 0, y: MindMoryShadow.softY)
    }
}
