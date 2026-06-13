import SwiftUI

struct ErrorStateView: View {

    let message: String

    var body: some View {
        EmptyStateView(
            title: "Something needs attention",
            message: message
        )
    }
}
