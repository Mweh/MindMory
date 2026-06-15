import SwiftUI

struct TextFieldComponent<Content: View>: View {
    let title: String
    let iconName: String?
    let borderColor: Color
    let content: Content

    init(
        title: String,
        iconName: String? = nil,
        borderColor: Color = MindMoryColors.Border.subtle,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.iconName = iconName
        self.borderColor = borderColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.xs) {
            Text(title)
                .font(MindMoryTypography.titleSmall)
                .foregroundStyle(MindMoryColors.Content.secondary)

            HStack(spacing: MindMorySpacing.sm) {
                if let iconName {
                    Image(systemName: iconName)
                        .foregroundStyle(MindMoryColors.Content.secondary)
                }

                content
                    .font(MindMoryTypography.bodyMedium)
            }
            .padding(MindMorySpacing.md)
            .frame(maxWidth: .infinity)
            .background(MindMoryColors.Surface.background)
            .clipShape(RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MindMoryRadius.small, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }
}

struct TextFieldComponent_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: MindMorySpacing.lg) {
            TextFieldComponent(title: "Album title", iconName: "pencil.tip") {
                TextField("Name your album", text: .constant(""))
            }

            TextFieldComponent(title: "Start", iconName: "calendar") {
                DatePicker("", selection: .constant(Date()), displayedComponents: .date)
                    .labelsHidden()
            }
        }
        .padding()
        .background(MindMoryColors.Surface.surface)
    }
}
