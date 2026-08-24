import SwiftUI

/// Aguach1leLabs design tokens (IOS_STANDARDS §6) — dark-first, one accent per app.
public enum AguaColor {
    public static let bgPrimary = Color(hex: 0x0B0E11)
    public static let bgSecondary = Color(hex: 0x111820)
    public static let bgCard = Color(hex: 0x1A2332)
    public static let bgElevated = Color(hex: 0x243040)

    public static let textPrimary = Color.white
    public static let textSecondary = Color(hex: 0xB8C4D0)
    public static let textMuted = Color(hex: 0x6B7A8D)

    public static let success = Color(hex: 0x3DAA6E)
    public static let warning = Color(hex: 0xE8A020)
    public static let error = Color(hex: 0xD94040)
    public static let info = Color(hex: 0x3A8AC4)

    /// The per-app accent family — pick ONE per app (5–10% of any screen).
    public enum Accent {
        public static let amber = Color(hex: 0xD4960A)   // GastroSnap, PlateSnap
        public static let green = Color(hex: 0x3DAA6E)   // OverLanded, Sidequest, TheRiseTrack
        public static let red = Color(hex: 0xD94040)     // PepperTalk, RoadMind, Challenger
        public static let blue = Color(hex: 0x3A8AC4)    // CalmBreak, MapWise
        public static let violet = Color(hex: 0x8A5AC4)  // YourMindSpark, LifeThread, FidgetLog
    }
}

/// Base-4 spacing grid.
public enum AguaSpacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
