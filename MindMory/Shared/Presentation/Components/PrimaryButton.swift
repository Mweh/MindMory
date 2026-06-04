import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindMoryTypography.button)
                .foregroundStyle(MindMoryColors.deepGreen)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MindMorySpacing.md)
                .background(MindMoryColors.background)
                .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                .overlay(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                        .stroke(MindMoryColors.primaryGreen, lineWidth: 1.4)
                    Rectangle()
                        .fill(MindMoryColors.primaryGreen)
                        .frame(height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                        .padding(.horizontal, 2)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview { PrimaryButton(title: "Continue", action: {}) .padding().background(MindMoryColors.background) }
