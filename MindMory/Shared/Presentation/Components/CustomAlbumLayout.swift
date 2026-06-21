import SwiftUI

struct CustomAlbumLayout<Content: View, Background: View>: View {
    private let content: Content
    private let background: Background
    private let padding: EdgeInsets
    private let scrollable: Bool
    private let contentAlignment: Alignment

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
        self.padding = padding
        self.scrollable = scrollable
        self.contentAlignment = alignment
        self.background = background()
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            background

            GeometryReader { geometry in
                VStack(spacing: .zero) {
                    AlbumTopCurveShape()
                        .fill(MindMoryColors.Surface.backgroundTop)
                        .frame(height: geometry.size.height * 0.37 + geometry.safeAreaInsets.top + 32)
                        .ignoresSafeArea(edges: .top)

                    Spacer()
                }
            }

            contentBody
        }
    }

    @ViewBuilder private var contentBody: some View {
        if scrollable {
            ScrollView(showsIndicators: false) {
                content
                    .frame(maxWidth: .infinity, alignment: contentAlignment)
                    .padding(padding)
                    .padding(.top, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        } else {
            content
                .frame(maxWidth: .infinity, alignment: contentAlignment)
                .padding(padding)
                .padding(.top, 16)
        }
    }
}

private struct AlbumTopCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.65))

        path.addCurve(
            to: CGPoint(x: rect.width * 0.6, y: rect.height * 0.78),
            control1: CGPoint(x: rect.width * 0.94, y: rect.height * 0.7),
            control2: CGPoint(x: rect.width * 0.8, y: rect.height * 0.82)
        )

        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.75),
            control1: CGPoint(x: rect.width * 0.3, y: rect.height * 0.74),
            control2: CGPoint(x: rect.width * 0.1, y: rect.height * 0.78)
        )

        path.closeSubpath()
        return path
    }
}
