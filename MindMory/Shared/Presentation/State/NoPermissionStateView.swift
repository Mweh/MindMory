import SwiftUI

struct NoPermissionStateView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let iconName: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: MindMorySpacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                    .fill(MindMoryColors.Surface.primary.opacity(0.14))
                    .frame(width: 76, height: 76)

                Image(systemName: iconName)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(MindMoryColors.Surface.primary)
            }

            VStack(spacing: MindMorySpacing.sm) {
                Text(title)
                    .font(MindMoryTypography.titleLarge)
                    .foregroundStyle(MindMoryColors.Content.primary)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.Content.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 360)

            PrimaryButton(title: buttonTitle, action: action)
                .frame(maxWidth: 280)
        }
        .padding(MindMorySpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .fill(MindMoryColors.Surface.surface)
        )
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                .stroke(MindMoryColors.Border.subtle, lineWidth: 1)
        }
        .shadow(color: MindMoryColors.Surface.primary.opacity(0.08), radius: 24, x: 0, y: 14)
    }
}

#if DEBUG
struct NoPermissionStateView_Previews: PreviewProvider {
    static var previews: some View {
        NoPermissionStateView(
            title: "Photos access is required",
            subtitle: "Allow photo access so MindMory can surface memories from nearby moments.",
            buttonTitle: "Allow Access",
            iconName: "photo.on.rectangle.angled",
            action: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
        .background(MindMoryColors.Surface.background)
    }
}
#endif
