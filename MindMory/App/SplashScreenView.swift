import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        PageLayout(
            scrollable: false,
            alignment: .center,
            background: {
                MindMoryColors.Surface.backgroundGradient
                    .ignoresSafeArea()
            }
        ) {
            VStack(spacing: 24) {
                Image("icon 1024")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)

                Text("MindMory")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(MindMoryColors.Content.primary)
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SplashScreenView()
}
