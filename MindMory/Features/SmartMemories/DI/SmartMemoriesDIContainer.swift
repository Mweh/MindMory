import Foundation
import SwiftUI

public final class SmartMemoriesDIContainer {
    
    @MainActor
    public static func createPeopleMemoriesView() -> some View {
        let libraryService = DefaultPhotoLibraryService()
        let analysisService = DefaultPhotoAnalysisService()
        let cache = DiskPhotoAnalysisCache()
        
        let viewModel = PeopleMemoriesViewModel(
            libraryService: libraryService,
            analysisService: analysisService,
            cache: cache
        )
        
        return PeopleMemoriesView(viewModel: viewModel)
    }
}
