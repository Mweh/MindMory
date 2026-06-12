# Album Detail View - Animation Sequence Diagram

## Complete Animation Timeline

```
TIMELINE (in seconds)
0.0 ─────────────────────────────────────────────── 1.0 ──────────────────────

HEADER SECTION
├─ [0.00 → 0.60] Header Container
│  ├─ [0.05 → 0.65] Album Title (textSection: slide-in from left + fade)
│  ├─ [0.10 → 0.80] Cover Image (imageSection: scale + fade)
│  ├─ [0.25 → 0.85] Date Text (textSection: slide-in from left + fade)
│  └─ [0.30 → 0.90] Photo Count (textSection: slide-in from left + fade)

SECTION 1 (Base delay: 0.35s)
├─ [0.35 → 1.00] Section Container (fade + scale)
│  ├─ Image Case:
│  │  ├─ [0.35 → 1.05] Cell 1 (imageSection: scale + fade)
│  │  ├─ [0.43 → 1.13] Cell 2 (imageSection: scale + fade, +0.08s stagger)
│  │  └─ [0.51 → 1.21] Cell 3 (imageSection: scale + fade, +0.16s stagger)
│  │
│  └─ Overlapped Case:
│     ├─ [0.35 → 1.10] Card 1 (overlapped: scale + rotate to -14°)
│     ├─ [0.45 → 1.20] Card 2 (overlapped: scale + rotate to +6°, +0.1s stagger)
│     └─ [0.55 → 1.30] Card 3 (overlapped: scale + rotate to -8°, +0.2s stagger)
│
│  Text Case:
│     ├─ [0.35 → 1.00] Title (textSection: slide-in)
│     └─ [0.45 → 1.10] Description (textSection: slide-in, +0.1s stagger)

SECTION 2 (Base delay: 0.47s = 0.35 + 0.12)
├─ [0.47 → 1.12] Section Container
│  └─ Same pattern as Section 1 but starts 0.12s later

SECTION 3 (Base delay: 0.59s = 0.35 + 0.24)
├─ [0.59 → 1.24] Section Container
│  └─ Same pattern as Section 1 but starts 0.24s later

SECTION N (Base delay: 0.35 + (N × 0.12))
└─ Pattern continues for each section
```

## Animation Effects Breakdown

### 1. HEADER ANIMATION
```
Effect: Scale + Fade
Scale: 0.95 → 1.0
Opacity: 0 → 1
Duration: 0.6s
Easing: easeOut

Visual: Card appears slightly small and fades in while growing to full size
```

### 2. TEXT SECTION ANIMATION
```
Effect: Horizontal Slide + Fade
Movement: X: -20px → 0
Opacity: 0 → 1
Duration: 0.65s per element
Easing: easeOut

Title and Description each have separate animations staggered by 0.1s
Visual: Text slides in from left, each element appears sequentially
```

### 3. IMAGE SECTION ANIMATION
```
Effect: Scale + Fade
Scale: 0.92 → 1.0
Opacity: 0 → 1
Duration: 0.7s
Easing: easeOut
Per-image delay: +0.08s

Visual: Images appear with slight upward movement and fade-in
Multiple images in one section animate one after another
```

### 4. OVERLAPPED CARD ANIMATION
```
Effect: Scale + Rotation + Fade
Scale: 0.85 → 1.0
Rotation: 0° → final rotation angle (-14°, +6°, -8°, etc)
Opacity: 0 → 1
Duration: 0.75s
Easing: easeOut
Per-card delay: +0.1s

Visual: Cards scale up from small size while rotating to final angle
Creates a layered, dynamic appearance
```

## Stagger Pattern Example (3 Sections)

```
Timeline visualization:
═════════════════════════════════════════════════════════

Header      ████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0.0-0.6s
            (animates continuously)

Section 1   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████░░░░ 0.35-1.0s
            (starts when header is 58% done)

Section 2   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████ 0.47-1.12s
            (starts 0.12s after Section 1)

Section 3   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0.59-1.24s
            (starts 0.12s after Section 2)

Spacing:    0.0 ─ 0.5 ─ 1.0 ─ 1.5 ─ 2.0 (seconds)
```

## How It Feels to User

1. **Initial Load**: Header appears smoothly with staggered internal animations
2. **Immediate Feedback**: Content starts appearing within 0.35s (feels responsive)
3. **Visual Flow**: Sections reveal themselves in sequence, creating rhythm
4. **Professional**: All animations coordinate, no jarring transitions
5. **Smooth Scroll**: Once all animations complete, scrolling remains fluid

## Spacing Layout

```
Top Padding (lg)
├─ Header (AppCard)
│  ├─ Title
│  ├─ Cover Image (16pt gap from title)
│  ├─ Date + Count (16pt gap from image)
│  └─ Total: 48pt internal spacing
├─ 16pt gap (md) ← Changed from 24pt (lg)
├─ Section 1 (16pt margin)
├─ 16pt gap (md)
├─ Section 2 (16pt margin)
├─ 16pt gap (md)
├─ Section 3 (16pt margin)
└─ Bottom Padding (lg)
```

## Timing Choreography

The key to smooth coordination:

1. **Header first**: Sets the stage (0-0.6s)
2. **Wait period**: 0.35s delay before first section (visual breathing room)
3. **Stagger**: Each section adds 0.12s to create cascading effect
4. **Per-element**: Within each section, elements add 0.08-0.1s delays
5. **Consistency**: All use easeOut for natural deceleration

## Result

- ✅ Smooth entrance experience
- ✅ Professional choreographed animations
- ✅ No overwhelming animation fatigue
- ✅ Clear visual hierarchy
- ✅ Responsive UI feedback
- ✅ Interesting but not distracting
- ✅ Works well on different scroll speeds
