import SwiftUI

public struct PeopleMemoriesView: View {
    @StateObject private var viewModel: PeopleMemoriesViewModel
    private let columns = [GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 2)]
    
    public init(viewModel: PeopleMemoriesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .idle, .loading:
                    ProgressView("Loading Photos...")
                case .permissionDenied:
                    VStack {
                        Image(systemName: "photo.badge.exclamationmark")
                            .font(.largeTitle)
                        Text("Photo Library Access Denied")
                            .font(.headline)
                        Text("Please enable photo access in Settings.")
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                case .analyzing:
                    VStack {
                        ProgressView(value: Double(viewModel.analyzedCount), total: Double(viewModel.totalToAnalyze))
                            .padding()
                        Text("Analyzing \(viewModel.analyzedCount) / \(viewModel.totalToAnalyze)")
                            .font(.caption)
                    }
                case .empty:
                    VStack {
                        Image(systemName: "person.crop.circle.badge.xmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No people found.")
                            .foregroundColor(.secondary)
                    }
                case .error(let message):
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text("Error: \(message)")
                    }
                case .loaded:
                    VStack {
                        // Temporary debug label
                        Text("Total Assets: \(viewModel.totalToAnalyze) | Analyzed: \(viewModel.analyzedCount) | People Photos: \(viewModel.memories.count)")
                            .font(.caption)
                            .padding(.top, 8)
                        
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(viewModel.memories) { memory in
                                    MemoryThumbnailView(asset: memory.asset)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Smart Memories")
            .onAppear {
                viewModel.loadMemories()
            }
            .onDisappear {
                viewModel.cancel()
            }
        }
    }
}
