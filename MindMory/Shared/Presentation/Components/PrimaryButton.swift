import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                    .fill(MindMoryColors.deepGreen)
                    .frame(height: 58)
                    .offset(y: 5)

                Text(title)
                    .font(MindMoryTypography.button)
                    .foregroundStyle(MindMoryColors.deepGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 58)
                    .background(MindMoryColors.background)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                            .stroke(MindMoryColors.primaryGreen, lineWidth: 1.4)
                    }
            }
            .padding(.bottom, 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview { PrimaryButton(title: "Continue", action: {}) .padding().background(MindMoryColors.background) }
