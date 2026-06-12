# Animation Customization Guide

Quick reference for adjusting animations in the Album Detail View.

## 🎯 Quick Adjustments

### Change Animation Durations
**File**: `ScrollAnimationModifier.swift`

```swift
// Find these lines and modify the duration value:

.easeOut(duration: 0.6)    // Header animation
.easeOut(duration: 0.65)   // Text animation
.easeOut(duration: 0.7)    // Image animation
.easeOut(duration: 0.75)   // Overlapped card animation

// Examples:
.easeOut(duration: 0.5)    // Faster
.easeOut(duration: 0.9)    // Slower
```

### Change Section Delays
**File**: `AlbumDetailView.swift` at line ~82

```swift
private func sectionCard(for section: MemoryAlbumSection, at index: Int) -> some View {
    let baseDelay = 0.35        // ← Change this
    let staggerDelay = Double(index) * 0.12  // ← Or change 0.12 (per-section gap)
    
    // Examples:
    let baseDelay = 0.25        // Start sections earlier
    let staggerDelay = Double(index) * 0.08  // Less gap between sections
    let staggerDelay = Double(index) * 0.15  // More gap between sections
}
```

### Change Header Element Delays
**File**: `AlbumDetailView.swift` at line ~20-55

```swift
.textSectionAnimation(delay: 0.05)    // Title - adjust this
.imageSectionAnimation(delay: 0.15)   // Image - adjust this
.textSectionAnimation(delay: 0.25)    // Date - adjust this
.textSectionAnimation(delay: 0.30)    // Count - adjust this
```

### Change Per-Image Delays
**File**: `AlbumDetailView.swift` at line ~125

```swift
private func detailImageCell(at index: Int, in section: MemoryAlbumSection, delay: Double = 0) -> some View {
    let cellDelay = delay + (Double(index) * 0.08)  // ← Change 0.08 for more/less stagger
    
    // Examples:
    let cellDelay = delay + (Double(index) * 0.05)  // Tighter stagger
    let cellDelay = delay + (Double(index) * 0.12)  // Looser stagger
}
```

### Change Animation Effects

#### Text Animation - Horizontal Offset
**File**: `ScrollAnimationModifier.swift` - `TextSectionAnimationModifier`

```swift
.offset(x: isVisible ? 0 : -20)  // ← Change -20 to different value
// -30: Further from left
// -10: Closer to left
// -50: Very far from left
```

#### Image Animation - Scale
**File**: `ScrollAnimationModifier.swift` - `ImageSectionAnimationModifier`

```swift
.scaleEffect(isVisible ? 1 : 0.92)  // ← Change 0.92
// 0.85: Smaller start (more dramatic)
// 0.95: Barely noticeable
// 0.80: Very dramatic scale
```

#### Header Animation - Scale
**File**: `ScrollAnimationModifier.swift` - `HeaderAnimationModifier`

```swift
.scaleEffect(isVisible ? 1 : 0.95)  // ← Change 0.95
// 0.90: Larger scale effect
// 0.98: Subtle effect
```

### Change Spacing Between Sections
**File**: `AlbumDetailView.swift` at line ~70

```swift
VStack(spacing: MindMorySpacing.md) {  // ← Change MindMorySpacing.md
    // Options from design system:
    // MindMorySpacing.xs   (8pt)   - Very tight
    // MindMorySpacing.sm   (12pt)  - Tight
    // MindMorySpacing.md   (16pt)  - Default
    // MindMorySpacing.lg   (20pt)  - Loose
    // MindMorySpacing.xl   (24pt)  - Very loose
}
```

## 🔄 Change Animation Type

### Change from Fade+Scale to Slide+Fade
Edit the animation modifier you want to change:

**Current (TextSectionAnimationModifier)**:
```swift
.offset(x: isVisible ? 0 : -20, y: isVisible ? 0 : 10)
```

**Alternative - slide from top**:
```swift
.offset(y: isVisible ? 0 : -30)
```

**Alternative - slide from right**:
```swift
.offset(x: isVisible ? 0 : 30)
```

### Change Easing Curve
Replace `.easeOut` with other options:

```swift
.easeOut(duration: 0.6)      // Current - natural deceleration
.easeInOut(duration: 0.6)    // Smooth both directions
.easeIn(duration: 0.6)       // Accelerating start
.linear(duration: 0.6)       // Constant speed
.spring()                     // Bouncy effect
.interpolatingSpring(        // Custom spring
    stiffness: 100,
    damping: 10,
    mass: 1
)
```

## 📊 Animation Formula Reference

### Standard Timing Pattern
```
Header:        0.0s (immediate)
Section 1:     0.35s (baseDelay)
Section 2:     0.47s (baseDelay + 0.12)
Section 3:     0.59s (baseDelay + 0.24)
Section N:     0.35 + (N × 0.12)
```

### Per-Element Pattern
```
Section base delay:    X
First element:         X + 0.0s
Second element:        X + 0.08s (images)
Third element:         X + 0.10s (overlapped cards)
Title:                 X + 0.0s
Description:           X + 0.1s (text only)
```

## 🎨 Preset Configurations

### Slow & Smooth (Luxurious)
```swift
// In ScrollAnimationModifier.swift
Header: duration: 0.8s
Text: duration: 0.85s
Image: duration: 0.9s
Overlapped: duration: 1.0s

// In AlbumDetailView.swift
baseDelay = 0.4
staggerDelay = Double(index) * 0.15
```

### Fast & Snappy (Energetic)
```swift
// In ScrollAnimationModifier.swift
Header: duration: 0.4s
Text: duration: 0.45s
Image: duration: 0.5s
Overlapped: duration: 0.55s

// In AlbumDetailView.swift
baseDelay = 0.25
staggerDelay = Double(index) * 0.08
```

### Minimal (Subtle & Professional)
```swift
// In ScrollAnimationModifier.swift
Header: duration: 0.5s, scale 0.98
Text: duration: 0.55s, offset: -10
Image: duration: 0.6s, scale 0.97
Overlapped: duration: 0.65s, scale 0.95

// In AlbumDetailView.swift
baseDelay = 0.3
staggerDelay = Double(index) * 0.1
```

## 🧪 Testing Changes

After any modification:

1. Run the app
2. Navigate to an album detail view
3. Watch the animation sequence
4. Check for:
   - ✅ Smooth transitions (no jumps)
   - ✅ Proper timing coordination
   - ✅ No animation overlap issues
   - ✅ Consistent feel across all sections
5. Test on device (not just simulator) for real performance
6. Test with multiple section counts (empty, 1, 3, 5)
7. Test scrolling up and down after animations complete

## 🐛 Common Issues & Fixes

### Animations feel slow/sluggish
→ Reduce duration values by 0.1-0.2s

### Animations feel too fast
→ Increase duration values by 0.1-0.2s

### Sections appear too close together
→ Increase `staggerDelay` value (0.12 → 0.15)

### Sections feel disconnected
→ Decrease `staggerDelay` value (0.12 → 0.10)

### Individual elements don't animate
→ Check if delay parameter is being passed correctly
→ Verify animation modifier is applied to correct view

### Animation stutters on scroll
→ Reduce scale effect range (0.92 → 0.96)
→ Reduce number of animations happening simultaneously

### Text doesn't slide properly
→ Increase offset value (-20 → -30)
→ Check that `withAnimation` is wrapping the state change

## 📝 Animation Checklist for Customization

- [ ] Identified which animation to modify
- [ ] Located the correct file and line number
- [ ] Changed the value (duration, delay, scale, offset, etc)
- [ ] Tested on simulator
- [ ] Tested on physical device
- [ ] Verified no performance issues
- [ ] Confirmed smooth visual appearance
- [ ] Checked coordination with other animations
