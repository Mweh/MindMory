import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(MindMorySecondaryButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        SecondaryButton(title: "Continue", action: {})
        SecondaryButton(title: "Disabled Button", action: {})
            .disabled(true)
    }
    .padding()
    .background(MindMoryColors.Surface.background)
}

private struct MindMorySecondaryButtonStyle: ButtonStyle {
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
        let pressDepth = (configuration.isPressed && isEnabled) ? Metrics.pressTravel : 0

        let shadowColor: Color = isEnabled ? MindMoryColors.Surface.primary : MindMoryColors.Border.strong
        let fillColor: Color = isEnabled ? MindMoryColors.Surface.elevated : MindMoryColors.Surface.disabled
        let borderColor: Color = isEnabled ? MindMoryColors.Border.subtle : MindMoryColors.Border.strong
        let textColor: Color = isEnabled ? MindMoryColors.Content.secondary : MindMoryColors.Content.secondary

        return Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: Metrics.faceHeight + Metrics.pressTravel)
            .background(alignment: .top) {
                RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous)
                    .fill(shadowColor)
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
                        .font(MindMoryTypography.labelLarge)
                        .foregroundStyle(textColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, Metrics.horizontalPadding)
                }
                .offset(y: pressDepth)
            }
            .contentShape(RoundedRectangle(cornerRadius: Metrics.cornerRadius, style: .continuous))
            .animation(Metrics.pressAnimation, value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isEnabled)
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
