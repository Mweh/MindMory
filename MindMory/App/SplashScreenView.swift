import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            MindMoryColors.Surface.background
                .ignoresSafeArea()

            VStack(spacing: MindMorySpacing.lg) {
                Image("icon 1024")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 120, height: 120)

                Text("MindMory")
                    .font(MindMoryTypography.display)
                    .foregroundStyle(MindMoryColors.Content.inverse)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, MindMorySpacing.xl)
        }
    }
}

#if DEBUG
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
#endif
