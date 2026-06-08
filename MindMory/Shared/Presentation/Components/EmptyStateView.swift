import SwiftUI

struct EmptyStateView: View {

    let title: String
    let message: String

    var body: some View {
        VStack {
            Image(systemName: "bell")
                .foregroundColor(MindMoryColors.primaryGreen)
                .font(MindMoryTypography.headingLarge)
            
            Text(title)
                .font(MindMoryTypography.headingLarge)
                .foregroundStyle(MindMoryColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding()

            Text(message)
                .font(MindMoryTypography.bodyLarge)
                .foregroundStyle(MindMoryColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.vertical)
        }
        .padding(MindMorySpacing.xl)
        .background(MindMoryColors.surface)
        .cornerRadius(MindMoryRadius.medium)
    }
}

#Preview {
    EmptyStateView(title: "Your first reminder is being prepared.", message: "We're learning the moments that matter to you so we can remind you at the right time")
}
