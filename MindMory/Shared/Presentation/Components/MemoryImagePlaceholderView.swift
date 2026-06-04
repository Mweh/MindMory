import SwiftUI

struct MemoryImagePlaceholderView: View {

    let imageName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backgroundGradient
            decorativeContent
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                MindMoryColors.surfaceStrong,
                MindMoryColors.surface,
                MindMoryColors.background
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var decorativeContent: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            overlappingCircles

            Image(systemName: "leaf.fill")
                .foregroundStyle(MindMoryColors.primaryGreen.opacity(0.55))
        }
        .padding(MindMorySpacing.md)
    }

    private var overlappingCircles: some View {
        HStack(spacing: -8) {
            Circle()
                .fill(MindMoryColors.primaryGreen.opacity(0.85))
                .frame(width: 44, height: 44)

            Circle()
                .fill(MindMoryColors.mutedIndigo.opacity(0.45))
                .frame(width: 44, height: 44)

            Circle()
                .fill(MindMoryColors.deepGreen.opacity(0.55))
                .frame(width: 44, height: 44)
        }
    }
}
