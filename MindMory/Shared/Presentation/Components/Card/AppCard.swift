import SwiftUI

struct AppCard<Content: View>: View {

    let backgroundColor: Color
    let content: Content

    init(
        backgroundColor: Color = MindMoryColors.Surface.surface,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    var body: some View {
        let cardShape = RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)

        content
            .padding(MindMorySpacing.lg)
            .background(cardShape.fill(backgroundColor))
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(MindMoryColors.Border.subtle, lineWidth: 1)
            )
    }
}
