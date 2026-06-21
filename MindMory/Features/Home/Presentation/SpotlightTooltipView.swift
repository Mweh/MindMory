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
            // Dark scrim. If cardFrame is not yet known, draw a plain scrim with no hole.
            Canvas { context, size in
                if cardFrame == .zero {
                    // Card not measured yet — fill entire screen
                    context.fill(
                        Path(CGRect(origin: .zero, size: size)),
                        with: .color(.black.opacity(0.74))
                    )
                } else {
                    var path = Path()
                    path.addRect(CGRect(origin: .zero, size: size))
                    path.addRoundedRect(
                        in: spotlightRect,
                        cornerSize: CGSize(width: cardCornerRadius, height: cardCornerRadius),
                        style: .continuous
                    )
                    context.fill(path, with: .color(.black.opacity(0.74)), style: FillStyle(eoFill: true))
                }
            }
            .ignoresSafeArea()
            .onTapGesture { dismiss() }

            // Tooltip bubble — above card if frame is known, centered if not
            if cardFrame == .zero {
                // Fallback: center on screen until GeometryReader fires
                VStack(spacing: MindMorySpacing.sm) {
                    Spacer()
                    tooltipBubble
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .allowsHitTesting(false)
            } else {
                VStack(spacing: MindMorySpacing.sm) {
                    tooltipBubble
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(MindMoryColors.Surface.primary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: max(0, spotlightRect.minY - MindMorySpacing.sm), alignment: .bottom)
                .allowsHitTesting(false)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.35)) { opacity = 1 }
        }
    }

    private var tooltipBubble: some View {
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
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) { opacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
    }
}

//#Preview {
//    SpotlightTooltipView()
//}
