import SwiftUI

struct ErrorStateView: View {

    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: MindMorySpacing.lg) {
            ZStack {
                Circle()
                    .fill(MindMoryColors.Feedback.error.opacity(0.14))
                    .frame(width: 92, height: 92)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                    .foregroundStyle(MindMoryColors.Feedback.error)
            }

            VStack(spacing: MindMorySpacing.sm) {
                Text("Something needs attention")
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: 360)

            if let retryAction {
                PrimaryButton(title: "Try Again", action: retryAction)
                    .padding(.top, MindMorySpacing.sm)
            }
        }
        .padding(MindMorySpacing.xl)
        .frame(maxWidth: .infinity)
        .background(MindMoryColors.Surface.surface)
        .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))
        .shadow(color: MindMoryColors.Surface.primary.opacity(0.08), radius: 20, x: 0, y: 10)
    }
}
