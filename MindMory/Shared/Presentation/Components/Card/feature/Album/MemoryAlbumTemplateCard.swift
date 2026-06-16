import SwiftUI

struct MemoryAlbumTemplate: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let suggestedName: String
    let note: String
    let iconName: String
    let accent: Color
    let sections: [MemoryAlbumSection]
}

struct MemoryAlbumTemplateCard: View {
    let template: MemoryAlbumTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            AppCard(backgroundColor: isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Surface.surface) {
                HStack(alignment: .center, spacing: MindMorySpacing.lg) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                        HStack(alignment: .top, spacing: MindMorySpacing.sm) {
                            ZStack {
                                RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
                                    .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.18) : MindMoryColors.Surface.primary.opacity(0.18))
                                    .frame(width: 42, height: 42)

                                Image(systemName: template.iconName)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.primary)
                            }

                            Spacer()
                        }

                        Text(template.title)
                            .font(MindMoryTypography.titleSmall)
                            .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(template.subtitle)
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(isSelected ? MindMoryColors.Content.inverseSecondary : MindMoryColors.Content.secondary)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .layoutPriority(1)
                    .frame(minHeight: 124, alignment: .top)

                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.12) : MindMoryColors.Surface.primary.opacity(0.12))

                        VStack(spacing: MindMorySpacing.xs) {
                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.35) : MindMoryColors.Surface.primary.opacity(0.35))
                                .frame(height: 24)

                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.24) : MindMoryColors.Surface.primary.opacity(0.24))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.24) : MindMoryColors.Surface.primary.opacity(0.24))
                                .frame(width: 36, height: 6)

                            RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                                .fill(isSelected ? MindMoryColors.Content.inverse.opacity(0.18) : MindMoryColors.Surface.primary.opacity(0.18))
                                .frame(width: 24, height: 6)

                            Spacer()
                        }
                        .padding(MindMorySpacing.sm)
                    }
                    .frame(width: 74, height: 80)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, MindMorySpacing.sm)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous))
    }
}
