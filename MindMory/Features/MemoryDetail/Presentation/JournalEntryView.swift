import SwiftUI

struct JournalEntryView: View {

    @Binding var text: String

    let saveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Journal")
                .font(MindMoryTypography.titleMedium)

            TextEditor(text: $text)
                .frame(minHeight: 110)
                .scrollContentBackground(.hidden)
                .background(MindMoryColors.Surface.surface)
                .clipShape(
                    RoundedRectangle(cornerRadius: MindMoryRadius.small)
                )

            Button("Save reflection", action: saveAction)
                .font(MindMoryTypography.labelLarge)
                .foregroundStyle(MindMoryColors.Surface.primary)
        }
        .padding(MindMorySpacing.lg)
        .mindMoryCardStyle()
    }
}
