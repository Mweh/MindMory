import SwiftUI

struct MemoryCardBackView: View {
    let memory: Memory
    @Binding var captionText: String
    let shareAction: () -> Void
    

    var body: some View {
        ZStack(alignment: .topTrailing) {
            botanicalDecoration
                .padding(MindMorySpacing.xl)

            VStack(alignment: .leading, spacing: MindMorySpacing.lg) {
                HStack(alignment: .top) {
                    Text("Take yourself back.")
                        .font(MindMoryTypography.titleMedium)
                        .foregroundStyle(MindMoryColors.Content.primary)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    ZStack(alignment: .topLeading) {
                        if captionText.isEmpty {
                            Text("Write a little note about this photo.")
                                .font(MindMoryTypography.bodyMedium)
                                .foregroundStyle(MindMoryColors.Content.secondary.opacity(0.65))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }

                        TextEditor(text: $captionText)
                            .font(MindMoryTypography.bodyMedium)
                            .foregroundStyle(MindMoryColors.Content.primary)
                            .lineSpacing(4)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 190)
                    }

                    Divider()
                        .overlay(MindMoryColors.Surface.primary.opacity(0.26))
                }

                Spacer(minLength: MindMorySpacing.md)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text(memory.dateText)
                        if let locationName = memory.locationName {
                            Text(locationName)
                        }
                    }
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.secondary)

                    Spacer()

                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                            .font(MindMoryTypography.labelMedium)
                            .foregroundStyle(MindMoryColors.Surface.primary)
                            .frame(width: 48, height: 48)
                            .background(MindMoryColors.Content.inverse.opacity(0.72))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(MindMorySpacing.xl)
        }
        .frame(maxWidth: .infinity, minHeight: 510, alignment: .topLeading)
        .background(backBackground)
        .clipShape(cardShape)
        .overlay { cardShape.stroke(MindMoryColors.Border.subtle.opacity(0.7), lineWidth: 1) }
    }

    private var botanicalDecoration: some View {
        VStack(spacing: -6) {
            Image(systemName: "leaf.fill")
                .font(MindMoryTypography.titleLarge)
                .rotationEffect(.degrees(-18))
            Image(systemName: "leaf.fill")
                .font(MindMoryTypography.titleLarge)
                .rotationEffect(.degrees(26))
                .offset(x: -18)
        }
        .foregroundStyle(MindMoryColors.Surface.primary.opacity(0.10))
        .allowsHitTesting(false)
    }

    private var backBackground: some View {
        MindMoryColors.Surface.elevated
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

#if DEBUG
struct MemoryCardBackView_Previews: PreviewProvider {
    static var previews: some View {
        MemoryCardBackView(memory: PreviewData.aromaMemory, captionText: .constant("Sample caption"), shareAction: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

// Inline #Preview removed to avoid inline @State preview macro warning. Use the existing PreviewProvider above.
