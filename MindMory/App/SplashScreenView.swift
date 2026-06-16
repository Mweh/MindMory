import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            MindMoryColors.Surface.primary
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image("icon 1024")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .foregroundColor(.white)

                Text("MindMory")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)

                Text("Memories that meet you where you are.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    SplashScreenView()
}
