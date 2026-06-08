import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
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
        let pressDepth = configuration.isPressed && isEnabled ? Metrics.pressTravel : 0
        let fillColor = isEnabled ? MindMoryColors.background : MindMoryColors.surfaceStrong
        let borderColor = isEnabled ? MindMoryColors.primaryGreen : MindMoryColors.border
        let textColor = isEnabled ? MindMoryColors.deepGreen : MindMoryColors.mutedIndigo

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
                    fillColor: fillColor,
                    borderColor: borderColor
                ) {
                    configuration.label
                        .font(MindMoryTypography.button)
                        .foregroundStyle(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, Metrics.horizontalPadding)
                }
                .offset(y: pressDepth)
            }
            .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
            .animation(Metrics.pressAnimation, value: configuration.isPressed)
    }
}

private struct ButtonFace<Label: View>: View {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let height: CGFloat
    let fillColor: Color
    let borderColor: Color
    @ViewBuilder let label: () -> Label

    var body: some View {
        label()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(fillColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
    }
}
