import SwiftUI

struct PageLayout<Content: View, Background: View>: View {
    private let content: Content
    private let background: Background
    private let padding: EdgeInsets
    private let scrollable: Bool
    private let contentAlignment: Alignment

    init(
        padding: EdgeInsets = EdgeInsets(
            top: MindMorySpacing.xl,
            leading: MindMorySpacing.xl,
            bottom: MindMorySpacing.xl,
            trailing: MindMorySpacing.xl
        ),
        scrollable: Bool = true,
        alignment: Alignment = .topLeading,
        @ViewBuilder background: @escaping () -> Background = { MindMoryColors.Surface.background.ignoresSafeArea() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.scrollable = scrollable
        self.contentAlignment = alignment
        self.background = background()
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background
            contentBody
        }
    }

    @ViewBuilder private var contentBody: some View {
        if scrollable {
            ScrollView(showsIndicators: false) {
                content
                    .frame(maxWidth: .infinity, alignment: contentAlignment)
                    .padding(padding)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            content
                .frame(maxWidth: .infinity, alignment: contentAlignment)
                .padding(padding)
        }
    }
}
