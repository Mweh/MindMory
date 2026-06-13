import SwiftUI

struct ShareableMemoryExportView: View {
    let memory: Memory
    let captionText: String
    var debugImageURL: URL? = nil

    var body: some View {
        ZStack {
            LinearGradient(colors: [MindMoryColors.Surface.background, MindMoryColors.Surface.surface], startPoint: .topLeading, endPoint: .bottomTrailing)

            StackedShareCardView(memory: memory, captionText: captionText, debugImageURL: debugImageURL, exportMode: true)
                .padding(70)
        }
        .frame(width: 1080, height: 1350)
    }
}
