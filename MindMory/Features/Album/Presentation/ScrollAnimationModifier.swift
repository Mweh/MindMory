import SwiftUI

// MARK: - Visibility Tracking Key
struct VisibilityTrackingKey: PreferenceKey {
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - Viewport Visibility Detector
struct ViewportVisibilityModifier: ViewModifier {
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkVisibility(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global)) { _, _ in
                            checkVisibility(geometry)
                        }
                        .preference(key: VisibilityTrackingKey.self, value: isVisible)
                }
            )
    }
    
    private func checkVisibility(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        // Consider visible if any part of the view is in the viewport
        let isInViewport = frame.maxY > 0 && frame.minY < UIScreen.main.bounds.height
        isVisible = isInViewport
    }
}

// MARK: - Section Animation Modifiers
struct SectionFadeInAnimationModifier: ViewModifier {
    @State private var isVisible = false
    @State private var hasTriggered = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkAndTrigger(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkAndTrigger(geometry)
                        }
                }
            )
    }
    
    private func checkAndTrigger(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !hasTriggered {
            hasTriggered = true
            withAnimation(.easeOut(duration: 0.6).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Image Section Animation
struct ImageSectionAnimationModifier: ViewModifier {
    @State private var isVisible = false
    @State private var hasTriggered = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.92)
            .offset(y: isVisible ? 0 : 15)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkAndTrigger(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkAndTrigger(geometry)
                        }
                }
            )
    }
    
    private func checkAndTrigger(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !hasTriggered {
            hasTriggered = true
            withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Text Section Animation
struct TextSectionAnimationModifier: ViewModifier {
    @State private var isVisible = false
    @State private var hasTriggered = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : -20, y: isVisible ? 0 : 10)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkAndTrigger(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkAndTrigger(geometry)
                        }
                }
            )
    }
    
    private func checkAndTrigger(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !hasTriggered {
            hasTriggered = true
            withAnimation(.easeOut(duration: 0.65).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Overlapped Image Card Animation
struct OverlappedCardAnimationModifier: ViewModifier {
    @State private var isVisible = false
    @State private var hasTriggered = false
    let delay: Double
    let rotation: Angle
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.85)
            .rotationEffect(isVisible ? rotation : .degrees(0))
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkAndTrigger(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkAndTrigger(geometry)
                        }
                }
            )
    }
    
    private func checkAndTrigger(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 100 && frame.minY < UIScreen.main.bounds.height - 100
        
        if isInViewport && !hasTriggered {
            hasTriggered = true
            withAnimation(.easeOut(duration: 0.75).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Header Animation
struct HeaderAnimationModifier: ViewModifier {
    @State private var isVisible = false
    @State private var hasTriggered = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95)
            .offset(y: isVisible ? 0 : -10)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkAndTrigger(geometry)
                        }
                        .onChange(of: geometry.frame(in: .global).minY) { _, _ in
                            checkAndTrigger(geometry)
                        }
                }
            )
    }
    
    private func checkAndTrigger(_ geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let isInViewport = frame.maxY > 0
        
        if isInViewport && !hasTriggered {
            hasTriggered = true
            withAnimation(.easeOut(duration: 0.6)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Extension for easy application
extension View {
    func sectionFadeInAnimation(delay: Double = 0) -> some View {
        modifier(SectionFadeInAnimationModifier(delay: delay))
    }
    
    func imageSectionAnimation(delay: Double = 0) -> some View {
        modifier(ImageSectionAnimationModifier(delay: delay))
    }
    
    func textSectionAnimation(delay: Double = 0) -> some View {
        modifier(TextSectionAnimationModifier(delay: delay))
    }
    
    func overlappedCardAnimation(delay: Double = 0, rotation: Angle) -> some View {
        modifier(OverlappedCardAnimationModifier(delay: delay, rotation: rotation))
    }
    
    func headerAnimation() -> some View {
        modifier(HeaderAnimationModifier())
    }
}
