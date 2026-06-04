import SwiftUI

struct AlbumMemoryCellView: View { let memory: Memory
    var body: some View { VStack(alignment:.leading, spacing:MindMorySpacing.sm){ MemoryImagePlaceholderView(imageName: memory.imageName).frame(height:130).clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large)); HStack { Text(memory.title).font(MindMoryTypography.bodyMedium).foregroundStyle(MindMoryColors.textPrimary).lineLimit(1); Spacer(); if memory.isFavorite { Image(systemName:"star.fill").foregroundStyle(MindMoryColors.primaryGreen) } }; Text(memory.dateText).font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.textSecondary); Text(memory.tags.prefix(2).joined(separator:" · ")).font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.primaryGreen) }.padding(MindMorySpacing.sm).background(MindMoryColors.background).clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.large)).overlay(RoundedRectangle(cornerRadius: MindMoryRadius.large).stroke(MindMoryColors.border)) }
}
#Preview { AlbumMemoryCellView(memory: PreviewData.aromaMemory).padding().background(MindMoryColors.background) }
