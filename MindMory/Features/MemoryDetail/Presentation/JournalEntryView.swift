import SwiftUI

struct JournalEntryView: View {

    @Binding var text: String

    let saveAction: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Journal")
                    .font(MindMoryTypography.headingMedium)

                TextEditor(text: $text)
                    .frame(minHeight: 110)
                    .scrollContentBackground(.hidden)
                    .background(MindMoryColors.surface)
                    .clipShape(
                        RoundedRectangle(cornerRadius: MindMoryRadius.medium)
                    )

                Button("Save reflection", action: saveAction)
                    .font(MindMoryTypography.bodyMedium)
                    .foregroundStyle(MindMoryColors.primaryGreen)
            }
        }
    }
}
