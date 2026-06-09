import SwiftUI

struct HomeCardStatePickerView: View {
    @Binding var selectedState: HomeCardState

    var body: some View {
        Picker("Choose a state:", selection: $selectedState) {
            ForEach(HomeCardState.allCases) { state in
                Text(state.title).tag(state)
            }
        }
        .pickerStyle(.inline)
    }
}

#Preview {
    @Previewable @State var selectedState: HomeCardState = .normal
    Form { HomeCardStatePickerView(selectedState: $selectedState) }
}
