//
//  SpotlightTooltipView.swift
//  MindMory
//
//  Created by Hadi Alfian Akbar on 15/06/26.
//

import SwiftUI

// MARK: Preference key

struct CardFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: Spotlight Tooltip

struct SpotlightTooltipView: View {
    let cardFrame: CGRect
    let onDismiss: () -> Void
    
    @State private var opacity: Double = 0
    
    // matches interactive memory card view's card shape corner radius
    private let cardCornerRadius: CGFloat = MindMoryRadius.large
    // a little breathing room
    private let spotlightPadding: CGFloat = 8
    
    private var spotlightRect: CGRect {
        cardFrame.insetBy(dx: -spotlightPadding, dy: -spotlightPadding)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            //dark scrim with card shape hole
            Canvas { context, size in
                var path = Path()
                //full screen rectangle
                path.addRect(CGRect(origin: .zero, size: size))
                //card cutout - evenOdd fill rule makes this area transparent
                path.addRoundedRect(
                    in: spotlightRect,
                    cornerSize: CGSize(width: cardCornerRadius, height: cardCornerRadius),
                    style: .continuous
                )
                context.fill(path, with: .color(.black.opacity(0.74)), style: FillStyle(eoFill: true))
            }
            .ignoresSafeArea()
            .onTapGesture { dismiss() }
            
            // Tooltip above the card — frame fills the space from screen top to
            // the card's top edge, content is pinned to the bottom of that frame.
            let topSpaceHeight = max(0, spotlightRect.minY - MindMorySpacing.sm)
            let shouldPlaceAbove = topSpaceHeight > 100

            GeometryReader { geometry in
                VStack(spacing: MindMorySpacing.sm) {
                    if shouldPlaceAbove {
                        Spacer(minLength: 0)
                    }

                    HStack(spacing: MindMorySpacing.sm) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(MindMoryColors.Content.inverse)
                        Text("Tap the photo to flip it\nand add a note behind it.")
                            .font(MindMoryTypography.bodySmall)
                            .foregroundStyle(MindMoryColors.Content.inverse)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, MindMorySpacing.lg)
                    .padding(.vertical, MindMorySpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: MindMoryRadius.large, style: .continuous)
                            .fill(MindMoryColors.Surface.primary)
                            .shadow(color: .black.opacity(0.22), radius: 20, x: 0, y: 8)
                    )
                    .padding(.horizontal, MindMorySpacing.xxl)

                    Image(systemName: shouldPlaceAbove ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(MindMoryColors.Surface.primary)
                        .rotationEffect(.degrees(shouldPlaceAbove ? 180 : 0))

                    if !shouldPlaceAbove {
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: shouldPlaceAbove ? topSpaceHeight : max(0, geometry.size.height - spotlightRect.maxY - MindMorySpacing.sm), alignment: shouldPlaceAbove ? .bottom : .top)
                .allowsHitTesting(false)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.35)) { opacity = 1 }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) { opacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
    }
}

//#Preview {
//    SpotlightTooltipView()
//}
