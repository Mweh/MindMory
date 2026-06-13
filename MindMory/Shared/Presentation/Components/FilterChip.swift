import SwiftUI

struct FilterChip: View {
    let title: String
    let systemImage: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Label(title, systemImage: systemImage)
                } else {
                    Text(title)
                }
            }
            .font(MindMoryTypography.labelSmall)
            .foregroundStyle(isSelected ? MindMoryColors.Content.inverse : MindMoryColors.Content.primary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, MindMorySpacing.md)
            .padding(.vertical, MindMorySpacing.sm)
            .background(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Surface.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? MindMoryColors.Surface.primary : MindMoryColors.Border.subtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: MindMorySpacing.sm) {
        FilterChip(title: "1 photo", systemImage: nil, isSelected: true) {}
        FilterChip(title: "2 photos", systemImage: nil, isSelected: false) {}
    }
    .padding()
    .background(MindMoryColors.Surface.background)
}
