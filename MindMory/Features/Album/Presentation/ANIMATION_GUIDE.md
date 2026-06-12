# Album Detail View Animation System

## Overview
A coordinated animation system has been implemented for the AlbumDetailView with smooth, staggered animations for different element types and sections.

## Animation Components

### 1. **Header Animation**
- **Modifier**: `headerAnimation()`
- **Effect**: Fade-in + subtle scale (0.95 → 1.0)
- **Duration**: 0.6s
- **Easing**: easeOut
- **Elements Animated**:
  - Album title (delay: 0.05s)
  - Cover photo/placeholder (delay: 0.10-0.15s)
  - Date and photo count (delay: 0.25-0.30s)

### 2. **Text Section Animations**
- **Modifier**: Uses `AnimatedTextSectionView`
- **Effect**: Slide-in from left + fade-in
- **Offset**: -15 pixels horizontally
- **Duration**: 0.6s per element
- **Stagger**: 0.1s between title and description
- **Timing**: Coordinated with section index delay
- **Easing**: easeOut

### 3. **Image Section Animations**
- **Modifier**: `imageSectionAnimation(delay:)`
- **Effect**: Fade-in + scale (0.92 → 1.0)
- **Offset**: Slight upward offset (15 pixels)
- **Duration**: 0.7s
- **Easing**: easeOut
- **Per-Image Stagger**: Each image in a section delays by +0.08s

### 4. **Overlapped Image Cards Animation**
- **Modifier**: `overlappedCardAnimation(delay:rotation:)`
- **Effect**: Fade-in + scale (0.85 → 1.0) + rotation to final angle
- **Duration**: 0.75s
- **Easing**: easeOut
- **Per-Card Stagger**: Each overlapped card delays by +0.10s
- **Rotation**: Animates from 0° to final rotation angle

## Timing & Delays

### Section-Level Timing
```
Header: 0.0s → 0.35s (animations complete by ~0.6s)
  ├── Title: 0.05s
  ├── Cover Image: 0.10-0.15s
  └── Meta info: 0.25-0.30s

First Section: 0.35s base delay
Second Section: 0.47s (0.35s + 0.12s)
Third Section: 0.59s (0.35s + 0.24s)
...

Per-section pattern:
  ├── Text section: slide-in from left at base delay
  ├── Image section: scale-fade at base delay
  │   ├── Image 1: +0.0s
  │   ├── Image 2: +0.08s
  │   └── Image 3: +0.16s
  └── Overlapped images: rotation+scale at base delay
      ├── Card 1: +0.0s
      ├── Card 2: +0.10s
      └── Card 3: +0.20s
```

## Spacing Adjustments

### Gap Between Sections
- **Before**: `MindMorySpacing.lg` (24pt) - static
- **After**: `MindMorySpacing.md` (16pt) - tighter for visual flow
- **Result**: Smoother visual connection between animated sections
- **Benefit**: Sections feel more connected during scroll, better pacing

## Animation Principles

1. **Coordination**: All animations start within the first 0.35s then stagger subsequent sections
2. **Easing**: All use `easeOut` for natural deceleration
3. **Consistency**: Similar element types use consistent durations and offsets
4. **Hierarchy**: Header completes first, then sections in order
5. **Smoothness**: No sudden transitions; all elements animate at coordinated speeds

## Component Files

- **ScrollAnimationModifier.swift**: Core animation modifiers and preference keys
- **AnimatedTextSectionView.swift**: Text-specific animations with title/description stagger
- **AlbumDetailView.swift**: Main view with integrated animations

## Usage Examples

```swift
// Apply header animation
.headerAnimation()

// Apply image section animation with delay
.imageSectionAnimation(delay: 0.35)

// Apply text section animation with delay
.textSectionAnimation(delay: 0.47)

// Apply overlapped card animation
.overlappedCardAnimation(delay: 0.59, rotation: .degrees(-14))
```

## Performance Considerations

- All animations use `.easeOut` timing curve for optimal GPU rendering
- Animations are triggered on `onAppear` for smooth entrance
- No complex calculations during animation phases
- State management is minimal per animation
- ScrollView uses `showsIndicators: false` for cleaner appearance

## Future Enhancements

1. **Scroll-based parallax**: Animate elements based on scroll position
2. **Scroll direction detection**: Different animations for scroll up vs down
3. **Interactive animations**: Tap to re-trigger animations
4. **Dynamic timing**: Adjust delays based on content complexity
5. **Gesture-driven animations**: Respond to swipe/drag interactions
