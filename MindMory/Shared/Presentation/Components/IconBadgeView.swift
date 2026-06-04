import SwiftUI

struct IconBadgeView: View {
    let systemName: String
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(MindMoryColors.primaryGreen)
            .frame(width: 36, height: 36)
            .background(MindMoryColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
    }
}
