import SwiftUI

struct AlbumDateCardView: View {
    @ObservedObject var viewModel: MemoryAlbumCreationViewModel

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: MindMorySpacing.sm) {
                Text("Album date")
                    .font(MindMoryTypography.bodySmall)
                    .foregroundStyle(MindMoryColors.Content.primary)

                Picker("Album date type", selection: $viewModel.isDateRange) {
                    Text("Single day").tag(false)
                    Text("Range").tag(true)
                }
                .pickerStyle(.segmented)

                DatePicker(
                    "Start date",
                    selection: $viewModel.albumDateStart,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                if viewModel.isDateRange {
                    DatePicker(
                        "End date",
                        selection: $viewModel.albumDateEnd,
                        in: viewModel.albumDateStart...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                }
            }
        }
    }
}

#if DEBUG
struct AlbumDateCardView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDateCardView(viewModel: MemoryAlbumCreationViewModel())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
