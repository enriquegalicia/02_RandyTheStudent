import SwiftUI

/// One app's visual identity: surfaces, text, semantic colours and colour scheme.
///
/// **Every app sets its own theme at launch** (`AguaTheme.current = .myApp` in the App's
/// `init`, before any view is built). Since 2026-10-06 this is a submission gate: App Review
/// rejected PepperTalk and FidgetLog under guidelines 4.3 / 4.2.6 (spam, app generation
/// services). Apps that share an icon style and one dark card UI read as output from a
/// template, so no two apps on the account may look like the same product. See
/// APP_REVIEW_4_3_GUARD.md. `house` is the old shared look, kept only so apps that haven't
/// been given an identity yet still build.
public struct AguaTheme: Sendable {
    public var colorScheme: ColorScheme
    public var bgPrimary: Color
    public var bgSecondary: Color
    public var bgCard: Color
    public var bgElevated: Color
    /// Hairline drawn around cards. Light themes need one; dark themes usually use `.clear`.
    public var cardBorder: Color
    public var textPrimary: Color
    public var textSecondary: Color
    public var textMuted: Color
    public var success: Color
    public var warning: Color
    public var error: Color
    public var info: Color

    public init(
        colorScheme: ColorScheme,
        bgPrimary: Color, bgSecondary: Color, bgCard: Color, bgElevated: Color,
        cardBorder: Color = .clear,
        textPrimary: Color, textSecondary: Color, textMuted: Color,
        success: Color, warning: Color, error: Color, info: Color
    ) {
        self.colorScheme = colorScheme
        self.bgPrimary = bgPrimary
        self.bgSecondary = bgSecondary
        self.bgCard = bgCard
        self.bgElevated = bgElevated
        self.cardBorder = cardBorder
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textMuted = textMuted
        self.success = success
        self.warning = warning
        self.error = error
        self.info = info
    }

    /// The original shared dark look (IOS_STANDARDS §6 before 2026-10-06). Not an identity:
    /// an app still on `house` fails `scripts/review_gate.sh`.
    public static let house = AguaTheme(
        colorScheme: .dark,
        bgPrimary: Color(hex: 0x0B0E11),
        bgSecondary: Color(hex: 0x111820),
        bgCard: Color(hex: 0x1A2332),
        bgElevated: Color(hex: 0x243040),
        textPrimary: .white,
        textSecondary: Color(hex: 0xB8C4D0),
        textMuted: Color(hex: 0x6B7A8D),
        success: Color(hex: 0x3DAA6E),
        warning: Color(hex: 0xE8A020),
        error: Color(hex: 0xD94040),
        info: Color(hex: 0x3A8AC4)
    )

    /// Set once in the App's `init`. Views read it while building their bodies.
    nonisolated(unsafe) public static var current: AguaTheme = .house
}

/// Colour tokens. They read the app's `AguaTheme.current`, so call sites stay the same
/// while every app keeps its own look.
public enum AguaColor {
    public static var bgPrimary: Color { AguaTheme.current.bgPrimary }
    public static var bgSecondary: Color { AguaTheme.current.bgSecondary }
    public static var bgCard: Color { AguaTheme.current.bgCard }
    public static var bgElevated: Color { AguaTheme.current.bgElevated }

    public static var textPrimary: Color { AguaTheme.current.textPrimary }
    public static var textSecondary: Color { AguaTheme.current.textSecondary }
    public static var textMuted: Color { AguaTheme.current.textMuted }

    public static var success: Color { AguaTheme.current.success }
    public static var warning: Color { AguaTheme.current.warning }
    public static var error: Color { AguaTheme.current.error }
    public static var info: Color { AguaTheme.current.info }

    /// Legacy accent swatches. New identities pick their own accent hex in their theme file
    /// instead of sharing one of these five with other apps.
    public enum Accent {
        public static let amber = Color(hex: 0xD4960A)
        public static let green = Color(hex: 0x3DAA6E)
        public static let red = Color(hex: 0xD94040)
        public static let blue = Color(hex: 0x3A8AC4)
        public static let violet = Color(hex: 0x8A5AC4)
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
