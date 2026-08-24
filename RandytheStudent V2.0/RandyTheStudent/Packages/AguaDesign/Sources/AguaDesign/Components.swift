import SwiftUI

/// Standard corner radii — pick one instead of a new magic number per screen.
public enum AguaRadius {
    public static let small: CGFloat = 10
    public static let medium: CGFloat = 14
    public static let large: CGFloat = 20
}

public extension View {
    /// The house dark background: fills `AguaColor.bgPrimary` edge to edge and
    /// forces dark mode, since the whole design language is dark-first.
    func aguaBackground() -> some View {
        self
            .background(AguaColor.bgPrimary.ignoresSafeArea())
            .preferredColorScheme(.dark)
    }

    /// The house card surface — a rounded rectangle filled with `AguaColor.bgCard`,
    /// the standard container for a row, stat tile, or content block.
    func aguaCard(radius: CGFloat = AguaRadius.medium) -> some View {
        self.background(RoundedRectangle(cornerRadius: radius).fill(AguaColor.bgCard))
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
