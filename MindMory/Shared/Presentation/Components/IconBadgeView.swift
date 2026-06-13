import SwiftUI

struct IconBadgeView: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(MindMoryTypography.labelSmall)
            .foregroundStyle(MindMoryColors.Surface.primary)
            .frame(width: 36, height: 36)
            .background(MindMoryColors.Surface.surface)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
    }
}
