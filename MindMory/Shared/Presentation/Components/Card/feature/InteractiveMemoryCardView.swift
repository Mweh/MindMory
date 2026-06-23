import SwiftUI
import UIKit
import Combine
import CoreMotion

struct InteractiveMemoryCardView: View {
    let memory: Memory
    var imageSource: MemoryImageSource
    @Binding var side: MemoryCardSide
    @Binding var captionText: String
    let flipAction: () -> Void
    let shareAction: () -> Void

    @State private var displayedSide: MemoryCardSide = .front
    @State private var flipRotation: Double = 0
    @State private var isFlipping = false
    @State private var dragTilt: CGSize = .zero
    @State private var isTouchActive = false
    @State private var isScrolling = false
    @State private var cardFrame: CGRect = .zero
    @State private var lastCardFrame: CGRect = .zero
    @State private var scrollResetTask: Task<Void, Never>?
    @State private var shouldUseMotionUpdates = false
    @State private var isKeyboardVisible = false
    @StateObject private var motionManager = DeviceMotionTiltManager()

    private var isBackVisible: Bool { displayedSide == .back }
    private var isCardVisible: Bool { cardFrame.intersects(UIScreen.main.bounds) }
    private var combinedTilt: CGSize {
        let motionTilt = (!isTouchActive && isCardVisible && !isScrolling && shouldUseMotionUpdates)
            ? motionManager.tilt
            : .zero
        return CGSize(width: motionTilt.width + dragTilt.width, height: motionTilt.height + dragTilt.height)
    }

    var body: some View {
        let card = ZStack {
            if isBackVisible {
                MemoryCardBackView(memory: memory, captionText: $captionText, shareAction: shareAction)
            } else {
                MemoryCardFrontView(memory: memory, imageSource: imageSource, photoParallax: .zero, contentParallax: .zero)
            }
        }
        .rotation3DEffect(.degrees(combinedTilt.height), axis: (x: 1, y: 0, z: 0), perspective: 0.75)
        .rotation3DEffect(.degrees(combinedTilt.width), axis: (x: 0, y: 1, z: 0), perspective: 0.75)
        .rotation3DEffect(.degrees(flipRotation), axis: (x: 0, y: 1, z: 0), perspective: 0.75)
        .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 16)
        .contentShape(cardShape)
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear { updateCardFrame(geometry.frame(in: .global)) }
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        updateCardFrame(newFrame)
                    }
            }
        )

        Group {
            if isBackVisible {
                card
            } else {
                card
                    .simultaneousGesture(dragGesture)
                    .onTapGesture(perform: flipCard)
            }
        }
        .onAppear {
            displayedSide = side
            updateMotionUsage()
        }
        .onChange(of: side) {
            updateMotionUsage()
        }
        .onChange(of: isKeyboardVisible) {
            updateMotionUsage()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onChanged { value in
                let translation = value.translation
                let horizontal = abs(translation.width)
                let vertical = abs(translation.height)

                if horizontal > vertical, horizontal > 10 {
                    isTouchActive = true
                    isScrolling = false
                    cancelScrollReset()

                    let horizontalTilt = min(max(translation.width / 30, -1), 1)
                    let verticalTilt = min(max(translation.height / 40, -1), 1)
                    let tiltRange = CGSize(width: 14, height: 10)

                    dragTilt = CGSize(
                        width: -horizontalTilt * tiltRange.width,
                        height: verticalTilt * tiltRange.height
                    )
                }
            }
            .onEnded { _ in
                isTouchActive = false
                withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82, blendDuration: 0)) {
                    dragTilt = .zero
                }
                beginScrollReset()
            }
    }

    private func updateCardFrame(_ newFrame: CGRect) {
        cardFrame = newFrame
        if isKeyboardVisible {
            return
        }

        if !newFrame.intersects(UIScreen.main.bounds) {
            resetTilts()
            return
        }

        let verticalMovement = abs(newFrame.minY - lastCardFrame.minY)
        if !isTouchActive, verticalMovement > 2 {
            isScrolling = true
            resetTilts()
            beginScrollReset()
        }

        lastCardFrame = newFrame
    }

    private func resetTilts() {
        isTouchActive = false
        withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82, blendDuration: 0)) {
            dragTilt = .zero
        }
        motionManager.resetTilt()
    }

    private func beginScrollReset() {
        cancelScrollReset()
        let task = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            isScrolling = false
        }
        scrollResetTask = task
    }

    private func cancelScrollReset() {
        scrollResetTask?.cancel()
        scrollResetTask = nil
    }

    private func flipCard() {
        guard !isFlipping, !isBackVisible else { return }
        isFlipping = true
        UIApplication.shared.dismissKeyboard()

        withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
            flipRotation = 90
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            displayedSide = displayedSide == .front ? .back : .front
            flipAction()
            updateMotionUsage()
            flipRotation = -90

            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                flipRotation = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.34) {
                isFlipping = false
            }
        }
    }

    private func updateMotionUsage() {
        shouldUseMotionUpdates = !isBackVisible && !isKeyboardVisible
        if shouldUseMotionUpdates {
            motionManager.startUpdates()
        } else {
            motionManager.stopUpdates()
            if isKeyboardVisible {
                resetTilts()
            }
        }
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: MindMoryRadius.medium, style: .continuous)
    }
}

private final class DeviceMotionTiltManager: ObservableObject {
    @Published var tilt: CGSize = .zero

    private let motionManager = CMMotionManager()
    private let motionQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "InteractiveMemoryCardView.MotionQueue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let updateInterval = 1.0 / 60.0
    private var smoothedTilt: CGSize = .zero
    private let smoothingFactor: CGFloat = 0.14
    private let minimumUpdateDelta: CGFloat = 0.3

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        guard !motionManager.isDeviceMotionActive else { return }

        motionManager.deviceMotionUpdateInterval = updateInterval
        motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] motion, _ in
            guard let self = self, let motion = motion else { return }
            let rollDegrees = CGFloat(motion.attitude.roll * 180.0 / .pi)
            let pitchDegrees = CGFloat(motion.attitude.pitch * 180.0 / .pi)
            let dampedRoll = min(max(rollDegrees, -10), 10)
            let dampedPitch = min(max(pitchDegrees, -10), 10)

            let nextWidth = smoothedTilt.width * (1 - smoothingFactor) + dampedRoll * smoothingFactor
            let nextHeight = smoothedTilt.height * (1 - smoothingFactor) + dampedPitch * smoothingFactor
            let nextTilt = CGSize(width: nextWidth, height: nextHeight)

            let deltaWidth = abs(nextTilt.width - smoothedTilt.width)
            let deltaHeight = abs(nextTilt.height - smoothedTilt.height)
            smoothedTilt = nextTilt

            guard deltaWidth > minimumUpdateDelta || deltaHeight > minimumUpdateDelta else {
                return
            }

            DispatchQueue.main.async { [weak self] in
                self?.tilt = nextTilt
            }
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        resetTilt()
    }

    func resetTilt() {
        smoothedTilt = .zero
        DispatchQueue.main.async { [weak self] in
            withAnimation(.interactiveSpring(response: 0.34, dampingFraction: 0.82, blendDuration: 0)) {
                self?.tilt = .zero
            }
        }
    }
}

#if DEBUG
struct InteractiveMemoryCardView_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveMemoryCardView(memory: PreviewData.aromaMemory, imageSource: PreviewData.aromaMemory.imageSource, side: .constant(.front), captionText: .constant(""), flipAction: {}, shareAction: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif

// Simple interactive preview
// Inline #Preview removed to avoid inline @State preview macro warning. Use the existing PreviewProvider above.
