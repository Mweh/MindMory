import SwiftUI

// ╔══════════════════════════════════════════════════════════════╗
// ║                    MindMory Typography                      ║
// ╚══════════════════════════════════════════════════════════════╝
//
// Single source of truth for all application typography.
//
// Architecture
// ──────────────────────────────────────────────────────────────
// Display   → Hero and marketing content
// Headline  → Screen titles
// Title     → Section and content hierarchy
// Body      → Readable content
// Label     → Interactive UI elements
//
// Font Family
// ──────────────────────────────────────────────────────────────
// SF Rounded is used across the system to provide a warm,
// approachable, and personal tone while preserving native
// iOS readability and Dynamic Type behavior.
//
// Rules
// ──────────────────────────────────────────────────────────────
// ✓ Use semantic tokens in UI code
// ✓ Follow SwiftUI semantic text styles
// ✓ Allow Dynamic Type scaling automatically
// ✓ Prefer hierarchy before creating new typography tokens
// ✗ Never use hard-coded font sizes in components
//

enum MindMoryTypography {

    // ═══════════════════════════════════════════════════════════
    // MARK: Display
    // ═══════════════════════════════════════════════════════════
    //
    // Highest emphasis typography.
    //
    // Used by:
    // • Onboarding
    // • Empty states
    // • Hero content
    //

    static let display = Font
        .system(.largeTitle, design: .rounded)
        .weight(.bold)

    static let displayLevel = display

    // ═══════════════════════════════════════════════════════════
    // MARK: Headline
    // ═══════════════════════════════════════════════════════════
    //
    // Primary screen title.
    //
    // Examples:
    // • Memories
    // • Settings
    // • Profile
    //

    static let headline = Font
        .system(.title, design: .rounded)
        .weight(.semibold)

    // ═══════════════════════════════════════════════════════════
    // MARK: Title
    // ═══════════════════════════════════════════════════════════
    //
    // Content hierarchy below the screen headline.
    //
    // large  → Major section titles
    // medium → Card and list titles
    // small  → Minor content titles
    //

    static let titleLarge = Font
        .system(.title2, design: .rounded)
        .weight(.semibold)

    static let titleMedium = Font
        .system(.title3, design: .rounded)
        .weight(.semibold)

    static let titleSmall = Font
        .system(.headline, design: .rounded)

    // ═══════════════════════════════════════════════════════════
    // MARK: Body
    // ═══════════════════════════════════════════════════════════
    //
    // Readable content and supporting information.
    //
    // large  → Primary descriptions
    // medium → Standard content
    // small  → Metadata and secondary information
    //

    static let bodyLarge = Font
        .system(.body, design: .rounded)

    static let bodyMedium = Font
        .system(.callout, design: .rounded)

    static let bodySmall = Font
        .system(.footnote, design: .rounded)

    // ═══════════════════════════════════════════════════════════
    // MARK: Label
    // ═══════════════════════════════════════════════════════════
    //
    // Interactive UI elements.
    //
    // Used by:
    // • Buttons
    // • Tabs
    // • Chips
    // • Badges
    // • Menus
    // • Segmented controls
    //
    // large  → Primary actions
    // medium → Standard controls
    // small  → Compact controls
    //

    static let labelLarge = Font
        .system(.callout, design: .rounded)
        .weight(.medium)

    static let labelMedium = Font
        .system(.subheadline, design: .rounded)
        .weight(.medium)

    static let labelSmall = Font
        .system(.caption, design: .rounded)
        .weight(.medium)
}
