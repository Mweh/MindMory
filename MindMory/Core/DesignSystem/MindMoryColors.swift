import SwiftUI

// ╔══════════════════════════════════════════════════════════════╗
// ║                      MindMory Colors                        ║
// ╚══════════════════════════════════════════════════════════════╝
//
// Single source of truth for all application colors.
//
// Architecture
// ──────────────────────────────────────────────────────────────
// Palette   → Raw color values (private)
// Surface   → Backgrounds and containers
// Content   → Text, icons, symbols, glyphs
// Border    → Dividers and outlines
// Feedback  → Success and error states
// State     → Interaction states
//
// Rules
// ──────────────────────────────────────────────────────────────
// ✓ Use semantic tokens in UI code
// ✓ Keep palette private
// ✓ Add semantic roles before adding new colors
// ✗ Never reference palette values outside this file
//

enum MindMoryColors {

    // ═══════════════════════════════════════════════════════════
    // MARK: Palette
    // ═══════════════════════════════════════════════════════════
    //
    // Raw color values.
    // Never use directly from UI code.
    //

    private enum Palette {

        // ──────────────────────────────────────────────────────
        // BRAND
        // ──────────────────────────────────────────────────────

        static let brandLighter = "7FA08E"
        static let brandLight   = "4A7A64"
        static let brand        = "235B43"
        static let brandDark    = "1B4936"
        static let brandDarker  = "14382A"

        // ──────────────────────────────────────────────────────
        // SUCCESS
        // ──────────────────────────────────────────────────────

        static let successLighter = "CFE6DA"
        static let successLight   = "7FB397"
        static let success        = "2F7055"
        static let successDark    = "245843"
        static let successDarker  = "193F31"

        // ──────────────────────────────────────────────────────
        // ERROR
        // ──────────────────────────────────────────────────────

        static let errorLighter = "F5D3D3"
        static let errorLight   = "E38E8E"
        static let error        = "C95050"
        static let errorDark    = "A53E3E"
        static let errorDarker  = "7A2E2E"

        // ──────────────────────────────────────────────────────
        // NEUTRAL
        // ──────────────────────────────────────────────────────

        static let white   = "FFFFFF"

        static let gray50  = "F5F7F6"
        static let gray200 = "C1C9C5"
        static let gray400 = "8E9A95"
        static let gray700 = "5A6460"
        static let gray900 = "232826"

        static let black   = "000000"
    }

    // ═══════════════════════════════════════════════════════════
    // MARK: Surface
    // ═══════════════════════════════════════════════════════════
    //
    // Background layers and containers.
    //
    // background → Screen background
    // surface    → Cards, sections, grouped containers
    // elevated   → Modal, sheet, dialog, overlay containers
    // primary    → Brand-colored surfaces
    // disabled   → Disabled containers
    //

    enum Surface {

        static let background = Color(hex: Palette.brand)

        static var backgroundGradient: LinearGradient {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: Palette.brandLighter), location: 0),
                    .init(color: Color(hex: Palette.white), location: 0.3),
                    .init(color: Color(hex: Palette.white), location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        }

        static let surface = Color(hex: Palette.gray50)

        static let elevated = Color(hex: Palette.white)

        static let primary = Color(hex: Palette.brandLight)

        static let disabled = Color(hex: Palette.gray200)
}

    // ═══════════════════════════════════════════════════════════
    // MARK: Content
    // ═══════════════════════════════════════════════════════════
    //
    // Foreground content.
    //
    // Used by:
    // • Text
    // • Icons
    // • SF Symbols
    // • Labels
    // • Glyphs
    //
    // primary   → Highest emphasis
    // secondary → Supporting content
    // tertiary  → Captions and hints
    // disabled  → Disabled content
    // inverse   → Content on dark surfaces
    // link      → Interactive text links
    //

    enum Content {

        static let primary = Color(hex: Palette.gray900)

        static let secondary = Color(hex: Palette.gray700)

        static let tertiary = Color(hex: Palette.gray400)

        static let disabled = Color(hex: Palette.gray200)

        static let inverse = Color(hex: Palette.white)

        static let inverseSecondary = Color.white.opacity(0.8)

        static let link = Color(hex: Palette.brand)
    }

    // ═══════════════════════════════════════════════════════════
    // MARK: Border
    // ═══════════════════════════════════════════════════════════
    //
    // Dividers and outlines.
    //
    // subtle → Default separation
    // strong → Higher emphasis
    //

    enum Border {

        static let subtle = Color(hex: Palette.gray200)

        static let strong = Color(hex: Palette.gray400)
    }

    // ═══════════════════════════════════════════════════════════
    // MARK: Feedback
    // ═══════════════════════════════════════════════════════════
    //
    // Status communication.
    //
    // Keep intentionally small.
    // MindMory does not use warning or info.
    //
    // success → Positive outcome
    // error   → Negative outcome
    //

    enum Feedback {

        static let success = Color(hex: Palette.success)

        static let error = Color(hex: Palette.error)
    }

    // ═══════════════════════════════════════════════════════════
    // MARK: State
    // ═══════════════════════════════════════════════════════════
    //
    // Interaction states.
    //
    // focus → Keyboard and accessibility focus indicator
    //

    enum State {

        static let focus = Color(hex: Palette.brand)
    }
}
