import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .font(MindMoryTypography.button)
            .foregroundStyle(MindMoryColors.primaryGreen)
            .frame(maxWidth: .infinity)
            .padding(.vertical, MindMorySpacing.md)
            .buttonStyle(.plain)
    }
}
