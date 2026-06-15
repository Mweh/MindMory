import SwiftUI
import UIKit

struct InteractiveMemoryCardView: View {
    let memory: Memory
    var assetLocalIdentifier: String? = nil
    @Binding var side: MemoryCardSide
    @Binding var captionText: String
    let flipAction: () -> Void
    let shareAction: () -> Void

    private var isBackVisible: Bool { side == .back }

    var body: some View {
        ZStack {
            if isBackVisible {
                MemoryCardBackView(memory: memory, captionText: $captionText, shareAction: shareAction)
            } else {
                MemoryCardFrontView(memory: memory, assetLocalIdentifier: assetLocalIdentifier, photoParallax: .zero, contentParallax: .zero)
            }
        }
        .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 16)
        .contentShape(cardShape)
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
            flipAction()
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

#if DEBUG
struct InteractiveMemoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMemoryCardView(memory: PreviewData.aromaMemory, assetLocalIdentifier: nil, side: .constant(.front), captionText: .constant(""), flipAction: {}, shareAction: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

// Simple interactive preview
// Inline #Preview removed to avoid inline @State preview macro warning. Use the existing PreviewProvider above.
