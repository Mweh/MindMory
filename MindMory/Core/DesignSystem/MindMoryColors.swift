import SwiftUI

enum MindMoryColors {
    
    /*
    ┌────────────────────────────────────────────────┐
    │ MindMory Color Palette Reference, Don't Delete │
    └────────────────────────────────────────────────┘

    BRAND
    ──────────────────────────────────────────────
    brandLighter      #7FA08E
    brandLight        #4A7A64
    brand             #235B43
    brandDark         #1B4936
    brandDarker       #14382A


    SUCCESS
    ──────────────────────────────────────────────
    successLighter    #CFE6DA
    successLight      #7FB397
    success           #2F7055
    successDark       #245843
    successDarker     #193F31


    ERROR
    ──────────────────────────────────────────────
    errorLighter      #F5D3D3
    errorLight        #E38E8E
    error             #C95050
    errorDark         #A53E3E
    errorDarker       #7A2E2E


    NEUTRAL
    ──────────────────────────────────────────────
    neutralLightest   #FFFFFF
    neutralLighter    #F5F7F6
    neutralLight      #C1C9C5
    neutral           #8E9A95
    neutralDark       #5A6460
    neutralDarker     #232826
    neutralDarkest    #000000
    */

    // MARK: - Backgrounds

    static let background = Color(hex: "#F5F7F6")

    // MARK: - Surfaces

    static let surface = Color(hex: "#EEF3EE")
    static let surfaceStrong = Color(hex: "#DDE7E0")
    static let infoSurface = Color(hex: "#E7F1E9")
    static let placeholderSurface = Color(hex: "#E9EFF9")

    // MARK: - Brand Colors

    static let primaryGreen = Color(hex: "#235B43")
    static let mutedIndigo = Color(hex: "#6F7F8F")

    // MARK: - Text Colors

    static let textPrimary = Color(hex: "#252927")
    static let textSecondary = Color(hex: "#666E68")

    // MARK: - Borders

    static let border = Color(hex: "#D4DDD7")

    // MARK: - Feedback States

    static let success = Color(hex: "#2F7055")
    static let error = Color(hex: "#C95050")

    // MARK: - Disabled / Neutral

    static let neutral = Color(hex: "#8E9A95")
}
