import SwiftUI
import UIKit

struct InteractiveMemoryCardView: View {
    let memory: Memory
    var imageSource: MemoryImageSource
    @Binding var side: MemoryCardSide
    @Binding var captionText: String
    let flipAction: () -> Void
    let shareAction: () -> Void

    @State private var displayedSide: MemoryCardSide = .front
    @State private var flipRotation: Double = 0
    @State private var isFlipping = false

    private var isBackVisible: Bool { displayedSide == .back }

    var body: some View {
        ZStack {
            if isBackVisible {
                MemoryCardBackView(memory: memory, captionText: $captionText, shareAction: shareAction)
            } else {
                MemoryCardFrontView(memory: memory, imageSource: imageSource, photoParallax: .zero, contentParallax: .zero)
            }
        }
        .rotation3DEffect(.degrees(flipRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.75)
        .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 16)
        .contentShape(cardShape)
        .onAppear { displayedSide = side }
        .onTapGesture(perform: flipCard)
    }

    private func flipCard() {
        guard !isFlipping else { return }
        isFlipping = true
        UIApplication.shared.dismissKeyboard()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            flipRotation = 90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            displayedSide = displayedSide == .front ? .back : .front
            flipAction()
            flipRotation = -90

            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                flipRotation = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
                isFlipping = false
            }
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

#if DEBUG
struct InteractiveMemoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMemoryCardView(memory: PreviewData.aromaMemory, imageSource: PreviewData.aromaMemory.imageSource, side: .constant(.front), captionText: .constant(""), flipAction: {}, shareAction: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

// Simple interactive preview
// Inline #Preview removed to avoid inline @State preview macro warning. Use the existing PreviewProvider above.
