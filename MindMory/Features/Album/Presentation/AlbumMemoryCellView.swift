import SwiftUI

struct AlbumMemoryCellView: View {

    let memory: Memory

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            imageView
            titleRow
            dateText
            tagText
        }
        .padding(MindMorySpacing.sm)
        .background(MindMoryColors.background)
        .clipShape(
            RoundedRectangle(cornerRadius: MindMoryRadius.large)
        )
        .overlay {
            RoundedRectangle(cornerRadius: MindMoryRadius.large)
                .stroke(MindMoryColors.border)
        }
    }

    private var imageView: some View {
        MemoryImagePlaceholderView(imageName: memory.imageName)
            .frame(height: 130)
            .clipShape(
                RoundedRectangle(cornerRadius: MindMoryRadius.large)
            )
    }

    private var titleRow: some View {
        HStack {
            Text(memory.title)
                .font(MindMoryTypography.bodyMedium)
                .foregroundStyle(MindMoryColors.textPrimary)
                .lineLimit(1)

            Spacer()

            if memory.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(MindMoryColors.primaryGreen)
            }
        }
    }

    private var dateText: some View {
        Text(memory.dateText)
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.textSecondary)
    }

    private var tagText: some View {
        Text(memory.tags.prefix(2).joined(separator: " · "))
            .font(MindMoryTypography.caption)
            .foregroundStyle(MindMoryColors.primaryGreen)
    }
}

#Preview {
    AlbumMemoryCellView(memory: PreviewData.aromaMemory)
        .padding()
        .background(MindMoryColors.background)
}
