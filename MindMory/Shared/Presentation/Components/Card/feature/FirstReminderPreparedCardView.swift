import SwiftUI

struct FirstReminderPreparedCardView: View {
    var body: some View {
        HomeStateCardContainer {
            VStack(spacing: MindMorySpacing.xl) {
                Image(systemName: "bell")
                    .font(MindMoryTypography.display)
                    .foregroundStyle(MindMoryColors.Content.link)

                Text("Your first reminder is\nbeing prepared.")
                    .font(MindMoryTypography.display)
                    .foregroundStyle(MindMoryColors.Content.link)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("We’re learning the\nmoments that matter to\nyou so we can remind you\nat the right time.")
                    .font(MindMoryTypography.bodyLarge)
                    .foregroundStyle(MindMoryColors.Content.link)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, MindMorySpacing.xl)
        }
    }
}

#if DEBUG
struct FirstReminderPreparedCardView_Previews: PreviewProvider {
    static var previews: some View {
        FirstReminderPreparedCardView()
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

struct HomeStateCardContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, minHeight: 430)
            .background(MindMoryColors.Surface.surface.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
                    .stroke(MindMoryColors.Border.subtle.opacity(0.55), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 12)
    }
}

#Preview {
    FirstReminderPreparedCardView()
        .padding()
        .background(MindMoryColors.Surface.background)
}
