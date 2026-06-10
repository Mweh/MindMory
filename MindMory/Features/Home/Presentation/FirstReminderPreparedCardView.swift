import SwiftUI

struct FirstReminderPreparedCardView: View {
    var body: some View {
        HomeStateCardContainer {
            VStack(spacing: MindMorySpacing.xl) {
                Image(systemName: "bell")
                    .font(.system(size: 54, weight: .regular))
                    .foregroundStyle(MindMoryColors.primaryGreen)

                Text("Your first reminder is\nbeing prepared.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(MindMoryColors.primaryGreen)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("We’re learning the\nmoments that matter to\nyou so we can remind you\nat the right time.")
                    .font(.system(size: 22, weight: .regular, design: .rounded))
                    .foregroundStyle(MindMoryColors.primaryGreen)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, MindMorySpacing.xl)
        }
    }
}

struct HomeStateCardContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, minHeight: 430)
            .background(MindMoryColors.surface.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
                    .stroke(MindMoryColors.border.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }
}

#Preview {
    FirstReminderPreparedCardView()
        .padding()
        .background(MindMoryColors.background)
}
