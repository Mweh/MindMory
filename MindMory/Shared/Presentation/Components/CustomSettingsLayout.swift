import SwiftUI

struct CustomSettingsLayout<Content: View, Background: View>: View {
    private let layout: CustomMemoriesLayout<Content, Background>

    init(
        padding: EdgeInsets = EdgeInsets(
            top: MindMorySpacing.xl,
            leading: MindMorySpacing.xl,
            bottom: 64,
            trailing: MindMorySpacing.xl
        ),
        scrollable: Bool = true,
        alignment: Alignment = .topLeading,
        @ViewBuilder background: @escaping () -> Background = { MindMoryColors.Surface.backgroundGradient.ignoresSafeArea() },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.layout = CustomMemoriesLayout(
            padding: padding,
            scrollable: scrollable,
            alignment: alignment,
            background: background,
            content: content
        )
    }

    var body: some View {
        layout
    }
}
