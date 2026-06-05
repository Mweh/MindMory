import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(MindMoryPrimaryButtonStyle())
    }
}

#Preview { PrimaryButton(title: "Continue", action: {}) .padding().background(MindMoryColors.background) }

private struct MindMoryPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    private enum Metrics {
        static let cornerRadius = MindMoryRadius.medium
        static let borderWidth: CGFloat = 1
        static let bottomBorderWidth: CGFloat = 6
        static let faceHeight: CGFloat = 58
        static let horizontalPadding = MindMorySpacing.md
        static let pressAnimation = Animation.interactiveSpring(response: 0.18, dampingFraction: 0.86, blendDuration: 0.12)
        static var pressTravel: CGFloat { bottomBorderWidth - borderWidth }
    }

    func makeBody(configuration: Configuration) -> some View {
        let pressDepth = configuration.isPressed ? Metrics.pressTravel : 0

        return Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.faceHeight + Metrics.pressTravel)
            .background(alignment: .top) {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .fill(MindMoryColors.primaryGreen)
                    .frame(height: Metrics.faceHeight)
                    .offset(y: Metrics.pressTravel)
            }
            .overlay(alignment: .top) {
                ButtonFace(
                    cornerRadius: Metrics.cornerRadius,
                    borderWidth: Metrics.borderWidth,
                    height: Metrics.faceHeight,
                    fillColor: MindMoryColors.background
                ) {
                    configuration.label
                        .font(MindMoryTypography.button)
                        .foregroundStyle(MindMoryColors.deepGreen)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, Metrics.horizontalPadding)
                }
                .offset(y: pressDepth)
            }
            .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
            .opacity(isEnabled ? 1 : 0.55)
            .animation(Metrics.pressAnimation, value: configuration.isPressed)
            .animation(.easeOut(duration: 0.18), value: isEnabled)
    }
}

private struct ButtonFace<Label: View>: View {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let height: CGFloat
    let fillColor: Color
    @ViewBuilder let label: () -> Label

    var body: some View {
        label()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(MindMoryColors.primaryGreen, lineWidth: borderWidth)
            }
    }
}
