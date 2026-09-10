//
//  GradeScaleSettings.swift
//  RandyTheStudent
//
//  A global (not per-class) preference for what grades are "out of" — the
//  original app hard-coded 0...10; some teachers grade out of 100, or some
//  other scale entirely. Backed by UserDefaults directly (not @AppStorage)
//  so it can be read from ClassStore, a plain @Observable class rather
//  than a View — @AppStorage's property wrapper only works in a View's
//  environment. SettingsView still uses @AppStorage with this same key,
//  so both stay in sync automatically.
//

import Foundation

enum GradeScaleSettings {
    static let userDefaultsKey = "gradeScaleMax"
    static let defaultMax: Double = 10
    static let presets: [Double] = [10, 100]

    /// The configured "out of" value — e.g. 10 or 100. Falls back to
    /// `defaultMax` if unset or if somehow stored as a non-positive number.
    static var currentMax: Double {
        let stored = UserDefaults.standard.double(forKey: userDefaultsKey)
        return stored > 0 ? stored : defaultMax
    }

    /// Grades must be at least 0, but the upper bound is deliberately more
    /// generous than the configured scale — a teacher awarding bonus points
    /// (e.g. 120 on a 100-point scale) shouldn't be blocked by their own
    /// scale setting. Still bounded (2x the scale) to catch obvious typos.
    static func validRange(max: Double) -> ClosedRange<Double> {
        0...(max * 2)
    }

    /// For placeholder/hint text, e.g. "0–100".
    static func placeholderText(max: Double) -> String {
        let maxText = max == max.rounded() ? String(Int(max)) : String(max)
        return "0–\(maxText)"
    }

    // Convenience for call sites that aren't already observing the setting
    // reactively (e.g. ClassStore, a plain @Observable class rather than a
    // View — a one-off validation check at the moment of an action doesn't
    // need to live-update). A View showing this on screen should instead
    // hold its own `@AppStorage(GradeScaleSettings.userDefaultsKey)` and
    // call `validRange(max:)`/`placeholderText(max:)` with that, so the UI
    // actually refreshes if the setting changes while it's visible.
    static var validRange: ClosedRange<Double> { validRange(max: currentMax) }
    static var placeholderText: String { placeholderText(max: currentMax) }
}
