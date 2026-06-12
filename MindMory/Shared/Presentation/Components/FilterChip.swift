import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(MindMoryTypography.bodySmall)
                .foregroundStyle(isSelected ? Color.white : MindMoryColors.textPrimary)
                .lineLimit(1)
                .truncationMode(.tail)
                .padding(.horizontal, MindMorySpacing.md)
                .padding(.vertical, MindMorySpacing.sm)
                .background(isSelected ? MindMoryColors.primaryGreen : MindMoryColors.surface)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? MindMoryColors.primaryGreen : MindMoryColors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: MindMorySpacing.sm) {
        FilterChip(title: "1 photo", isSelected: true) {}
        FilterChip(title: "2 photos", isSelected: false) {}
    }
    .padding()
    .background(MindMoryColors.background)
}
