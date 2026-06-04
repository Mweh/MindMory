import SwiftUI

struct AlbumMemoryGridView: View {

    let memories: [Memory]
    let container: DependencyContainer

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: MindMorySpacing.md) {
                ForEach(memories) { memory in
                    NavigationLink {
                        MemoryDetailView(
                            viewModel: container.makeMemoryDetailViewModel(memory: memory)
                        )
                    } label: {
                        AlbumMemoryCellView(memory: memory)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
