import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(MindMoryTypography.labelMedium)
            .foregroundStyle(MindMoryColors.Surface.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MindMorySpacing.md)
            .buttonStyle(.plain)
    }
}
