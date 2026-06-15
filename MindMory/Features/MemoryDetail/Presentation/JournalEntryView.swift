import SwiftUI
import UIKit

struct JournalEntryView: View {

    @Binding var text: String
    @FocusState private var isTextEditorFocused: Bool

    let saveAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
            Text("Journal")
                .font(MindMoryTypography.titleMedium)

            TextEditor(text: $text)
                .focused($isTextEditorFocused)
                .frame(minHeight: 110)
                .scrollContentBackground(.hidden)
                .background(MindMoryColors.Surface.surface)
                .clipShape(
                    RoundedRectangle(cornerRadius: MindMoryRadius.small)
                )

            Button("Save reflection") {
                UIApplication.shared.dismissKeyboard()
                saveAction()
            }
            .font(MindMoryTypography.labelLarge)
            .foregroundStyle(MindMoryColors.Surface.primary)
        }
        .padding(MindMorySpacing.lg)
        .mindMoryCardStyle()
    }
}
