import SwiftUI

struct HomeMemoryFrameView: View { let memory: Memory; var compact = false
    var body: some View { AppCard { HStack(alignment:.top, spacing: MindMorySpacing.md){ VStack(alignment:.leading, spacing:MindMorySpacing.xs){ if let location=memory.locationName { Label(location, systemImage:"mappin.circle").font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.textSecondary) }; Text(memory.dateText).font(MindMoryTypography.caption).foregroundStyle(MindMoryColors.textSecondary); Text(memory.subtitle).font(compact ? MindMoryTypography.bodySmall : MindMoryTypography.bodyLarge).foregroundStyle(MindMoryColors.textPrimary).lineSpacing(3) }; Spacer(); MemoryImagePlaceholderView(imageName: memory.imageName).frame(width: compact ? 72 : 104, height: compact ? 72 : 104).clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium)) } } }
}
