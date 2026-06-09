import SwiftUI

struct CardHighlightOverlay: View {
    let dragOffset: CGSize
    let isDragging: Bool

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.white.opacity(isDragging ? 0.38 : 0.16), Color.white.opacity(isDragging ? 0.14 : 0.05), Color.white.opacity(0)], center: .center, startRadius: 4, endRadius: 180)
                .frame(width: 280, height: 280)
                .offset(x: dragOffset.width * 0.72, y: dragOffset.height * 0.62)
                .blendMode(.screen)

            LinearGradient(colors: [Color.white.opacity(0.16), Color.white.opacity(0.03), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                .blendMode(.softLight)
        }
        .allowsHitTesting(false)
    }
}
