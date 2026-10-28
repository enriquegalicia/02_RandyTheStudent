import SwiftUI

/// Standard corner radii — pick one instead of a new magic number per screen.
public enum AguaRadius {
    public static let small: CGFloat = 10
    public static let medium: CGFloat = 14
    public static let large: CGFloat = 20
}

public extension View {
    /// The app's background: fills `AguaColor.bgPrimary` edge to edge and applies the
    /// theme's colour scheme (`AguaTheme.current`).
    func aguaBackground() -> some View {
        self
            .background(AguaColor.bgPrimary.ignoresSafeArea())
            .preferredColorScheme(AguaTheme.current.colorScheme)
    }

    /// The card surface — a rounded rectangle filled with `AguaColor.bgCard` (plus the
    /// theme's hairline border), the standard container for a row, stat tile, or content block.
    func aguaCard(radius: CGFloat = AguaRadius.medium) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: radius)
                .fill(AguaColor.bgCard)
                .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(AguaTheme.current.cardBorder, lineWidth: 1))
        )
    }

    /// A step up from `aguaCard` for a surface that should read as "raised"
    /// above regular cards (e.g. a selected state).
    func aguaElevated(radius: CGFloat = AguaRadius.medium) -> some View {
        self.background(RoundedRectangle(cornerRadius: radius).fill(AguaColor.bgElevated))
    }
}

/// A small-caps section label, used to group related rows/cards under a
/// named category (e.g. YourMindSpark's game groups, SteadyMind's exercise groups).
/// One shared component instead of every app defining its own copy.
public struct AguaGroupHeader: View {
    private enum Content {
        case localized(LocalizedStringKey)
        case verbatim(String)
    }
    private let content: Content

    /// For a static label — participates in String Catalog localization,
    /// same as `Text(_ key: LocalizedStringKey)`. A string literal call site
    /// resolves here (matching `Text`'s own overload-resolution behavior).
    public init(_ title: LocalizedStringKey) {
        content = .localized(title)
    }

    /// For a dynamic, already-known string — user-entered data, or a value
    /// already resolved via `String(localized:)` — displayed as-is, same as
    /// `Text(verbatim:)`. Matches any `StringProtocol` value so existing
    /// `AguaGroupHeader(String(localized: "…"))` call sites keep compiling.
    ///
    /// `@_disfavoredOverload` is load-bearing, not decoration (added 2026-09-08). Without
    /// it a *string literal* call site — `AguaGroupHeader("Quests")` — resolved here rather
    /// than to the `LocalizedStringKey` init above, because `String` is a literal's default
    /// type. The header was then rendered with `Text(verbatim:)` and **never localized**, so
    /// every section header in every app stayed in English no matter what the catalog said.
    /// Caught by WanderClue's Spanish pass: the translations were present and compiled into
    /// `es.lproj`, and the headers were still English on screen. The attribute pushes literals
    /// to the localized init while dynamic `String` values (which can't be a `LocalizedStringKey`)
    /// still land here — so no call site anywhere had to change.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S) {
        content = .verbatim(String(title))
    }

    public var body: some View {
        Group {
            switch content {
            case .localized(let key):
                // Explicit `bundle: .main`: Text's default localization
                // lookup infers the *source file's own* module bundle, which
                // for code living here would always be AguaDesign's bundle
                // (no strings of its own) instead of the consuming app's —
                // silently falling back to English for every caller.
                Text(key, bundle: .main)
            case .verbatim(let string):
                Text(verbatim: string)
            }
        }
        .textCase(.uppercase)
        .font(.caption.bold())
        .tracking(1)
        .foregroundStyle(AguaColor.textMuted)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, AguaSpacing.xs)
    }
}
