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
                        .font(MindMoryTypography.headingLarge)
                        .foregroundStyle(MindMoryColors.textPrimary)

                    Spacer()

                    Image(systemName: memory.isFavorite ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(MindMoryColors.primaryGreen)
                }

                VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                    ZStack(alignment: .topLeading) {
                        if captionText.isEmpty {
                            Text("Write a little note about this photo.")
                                .font(MindMoryTypography.bodyMedium)
                                .foregroundStyle(MindMoryColors.textSecondary.opacity(0.65))
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $captionText)
                            .font(MindMoryTypography.bodyMedium)
                            .foregroundStyle(MindMoryColors.textPrimary)
                            .lineSpacing(4)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 190)
                    }

                    Divider()
                        .overlay(MindMoryColors.primaryGreen.opacity(0.26))
                }

                Spacer(minLength: MindMorySpacing.md)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
                        Text(memory.dateText)
                        if let locationName = memory.locationName {
                            Text(locationName)
                        }
                    }
                    .font(MindMoryTypography.caption)
                    .foregroundStyle(MindMoryColors.textSecondary)

                    Spacer()

                    Button(action: shareAction) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .foregroundStyle(MindMoryColors.primaryGreen)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.72))
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
        .overlay { cardShape.stroke(MindMoryColors.border.opacity(0.7), lineWidth: 1) }
    }

    private var botanicalDecoration: some View {
        VStack(spacing: -6) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 54))
                .rotationEffect(.degrees(-18))
            Image(systemName: "leaf.fill")
                .font(.system(size: 36))
                .rotationEffect(.degrees(26))
                .offset(x: -18)
        }
        .foregroundStyle(MindMoryColors.primaryGreen.opacity(0.10))
        .allowsHitTesting(false)
    }

    private var backBackground: some View {
        LinearGradient(colors: [Color(hex: "#F6F2E4"), Color(hex: "#EAF1E9"), Color(hex: "#FFF7E6")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.extraLarge, style: .continuous)
    }
}
