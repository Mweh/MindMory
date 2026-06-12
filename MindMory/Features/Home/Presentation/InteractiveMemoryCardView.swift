import SwiftUI

struct InteractiveMemoryCardView: View {
    let memory: Memory
    var assetLocalIdentifier: String? = nil
    var debugImageURL: URL? = nil
    @Binding var side: MemoryCardSide
    @Binding var captionText: String
    let flipAction: () -> Void
    let shareAction: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false

    private var rotationX: Double { Double(-dragOffset.height / 12).clamped(to: -15...15) }
    private var rotationY: Double { Double(dragOffset.width / 12).clamped(to: -15...15) }
    private var isBackVisible: Bool { side == .back }
    private var photoParallax: CGSize { CGSize(width: dragOffset.width / 30, height: dragOffset.height / 34) }
    private var contentParallax: CGSize { CGSize(width: dragOffset.width / 48, height: dragOffset.height / 54) }

    var body: some View {
        ZStack {
            MemoryCardFrontView(memory: memory, assetLocalIdentifier: assetLocalIdentifier, debugImageURL: debugImageURL, photoParallax: photoParallax, contentParallax: contentParallax)
                .opacity(isBackVisible ? 0 : 1)
                .rotation3DEffect(.degrees(isBackVisible ? 180 : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.7)

            MemoryCardBackView(memory: memory, captionText: $captionText, shareAction: shareAction)
                .opacity(isBackVisible ? 1 : 0)
                .rotation3DEffect(.degrees(isBackVisible ? 0 : -180), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
        }
        .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0), perspective: 0.7)
        .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 0.7)
        .overlay { CardHighlightOverlay(dragOffset: dragOffset, isDragging: isDragging).clipShape(cardShape) }
        .shadow(color: .black.opacity(isDragging ? 0.22 : 0.13), radius: isDragging ? 28 : 18, x: -dragOffset.width / 12, y: max(10, dragOffset.height / 12 + 16))
        .scaleEffect(isDragging ? 1.015 : 1)
        .contentShape(cardShape)
        .gesture(cardGesture)
        .animation(.spring(response: 0.46, dampingFraction: 0.82), value: side)
        .animation(.interactiveSpring(response: 0.28, dampingFraction: 0.78), value: dragOffset)
    }

    private var cardGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation
            }
            .onEnded { value in
                let distance = hypot(value.translation.width, value.translation.height)
                withAnimation(.spring(response: 0.44, dampingFraction: 0.8)) {
                    dragOffset = .zero
                    isDragging = false
                }
                if distance < 8 {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    flipAction()
                }
            }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
    }
}

private extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
