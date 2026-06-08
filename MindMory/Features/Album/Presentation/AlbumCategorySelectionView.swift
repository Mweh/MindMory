import SwiftUI

struct AlbumCategorySelectionView<TimelineDestination: View, MemoryDestination: View>: View {
    let timelineDestination: TimelineDestination
    let memoryDestination: MemoryDestination

    var body: some View {
        VStack(spacing: MindMorySpacing.xxl) {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Choose an album type")
                    .font(MindMoryTypography.displayLarge)
                    .foregroundStyle(MindMoryColors.textPrimary)

                Text("Select which album experience you want to create today.")
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.textSecondary)
            }
            .padding(.top, MindMorySpacing.xxxl)

            VStack(spacing: MindMorySpacing.lg) {
                NavigationLink(destination: timelineDestination) {
                    AlbumCategoryCard(
                        title: "Timeline Album",
                        subtitle: "Capture a sequence of moments with a cover photo and extra images.",
                        systemImage: "clock.arrow.circlepath"
                    )
                }

                NavigationLink(destination: memoryDestination) {
                    AlbumCategoryCard(
                        title: "Memory Album",
                        subtitle: "Collect a memory set with a mood-driven style and vivid storytelling.",
                        systemImage: "sparkles"
                    )
                }
            }

            Spacer()
        }
        .padding(MindMorySpacing.xl)
        .background(MindMoryColors.background.ignoresSafeArea())
        .navigationTitle("New Album")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AlbumCategoryCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: MindMorySpacing.lg) {
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(MindMoryColors.primaryGreen)
                    .frame(width: 48, height: 48)
                    .background(MindMoryColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous))

                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    Text(title)
                        .font(MindMoryTypography.headingMedium)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Text(subtitle)
                        .font(MindMoryTypography.bodySmall)
                        .foregroundStyle(MindMoryColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(MindMorySpacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        AlbumCategorySelectionView(
            timelineDestination: Text("Timeline Destination"),
            memoryDestination: Text("Memory Destination")
        )
    }
}
