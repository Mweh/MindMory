import SwiftUI
import UIKit

struct ShareableMemoryExportView: View {
    let memory: Memory
    let captionText: String
    let resolvedImage: UIImage?
    let fallbackImageName: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: [MindMoryColors.Surface.background, MindMoryColors.Surface.surface], startPoint: .topLeading, endPoint: .bottomTrailing)

            StackedShareCardView(
                memory: memory,
                captionText: captionText,
                resolvedImage: resolvedImage,
                fallbackImageName: fallbackImageName,
                exportMode: true
            )
            .padding(70)
        }
        .frame(width: 1080, height: 1350)
    }
}
