//
//  RandyTheStudentApp.swift
//  RandyTheStudent
//

import SwiftUI
import AguaDesign

@main
struct RandyTheStudentApp: App {
    init() {
        // RandoSquad's own look (see `AguaTheme.randoSquad` below), not the shared portfolio one.
        AguaTheme.current = .randoSquad
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - RandoSquad's own look

// A chalkboard, taken from the app icon: board-green surfaces, chalk-white text, and chalk as the
// identity colour. Main actions are chalk buttons with board-green text (`.chalk` below); a pale
// chalk blue marks symbols on the board, and a deeper one fills swipe actions so their white icons
// stay readable. App Review rejected the shared portfolio look under 4.3 (2026-10-06); see
// APP_REVIEW_4_3_GUARD.md in the Aguach1leLabs repo.
extension AguaTheme {
    static let randoSquad = AguaTheme(
        colorScheme: .dark,
        bgPrimary: Color(hex: 0x1A3A30),    // the board, a shade under the icon's
        bgSecondary: Color(hex: 0x1E4236),
        bgCard: Color(hex: 0x1E4A38),       // the icon's board
        bgElevated: Color(hex: 0x285A47),
        cardBorder: Color(hex: 0x3A5F50),   // a chalk smudge
        textPrimary: Color(hex: 0xF2EFE2),  // the icon's chalk
        textSecondary: Color(hex: 0xCBD8CF),
        textMuted: Color(hex: 0x9DB5A7),
        success: Color(hex: 0x7FD6A8),
        warning: Color(hex: 0xF2C46B),
        error: Color(hex: 0xFF8A7A),
        info: Color(hex: 0x8EC1E0)
    )
}

extension Color {
    /// The icon's chalk, RandoSquad's identity colour (AccentColor matches it).
    static let chalk = Color(hex: 0xF2EFE2)
    /// Text on chalk: the icon's darkest board green.
    static let board = Color(hex: 0x163A2C)
    /// Pale chalk blue for symbols on the board.
    static let chalkBlue = Color(hex: 0x8EC1E0)
    /// A deeper chalk blue behind white icons (swipe actions).
    static let chalkBlueDeep = Color(hex: 0x3F7299)
}

/// A main action written in chalk: a chalk-filled button with board-green text. Replaces
/// `.borderedProminent`, whose white label would vanish on a chalk tint.
struct ChalkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ChalkButton(configuration: configuration)
    }

    private struct ChalkButton: View {
        let configuration: ButtonStyleConfiguration
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.body.weight(.semibold))
                .foregroundStyle(Color.board)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(RoundedRectangle(cornerRadius: AguaRadius.small).fill(Color.chalk))
                .opacity(isEnabled ? (configuration.isPressed ? 0.75 : 1) : 0.4)
        }
    }
}

extension ButtonStyle where Self == ChalkButtonStyle {
    static var chalk: ChalkButtonStyle { ChalkButtonStyle() }
}

/// Text fields as slate boxes on the board; `.roundedBorder` draws them black on the green.
struct ChalkFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: AguaRadius.small).fill(AguaColor.bgElevated))
            .overlay(RoundedRectangle(cornerRadius: AguaRadius.small).strokeBorder(AguaTheme.current.cardBorder, lineWidth: 1))
    }
}

extension TextFieldStyle where Self == ChalkFieldStyle {
    static var chalk: ChalkFieldStyle { ChalkFieldStyle() }
}

/// Launch arguments for App Store screenshots (scripts/capture_screens.py), Debug builds only:
/// `-uiTestSeed` (renames the default class, fills it with twelve fictional students, groups,
/// a graded activity and some participation, then opens it), `-uiTestTab 0…4`.
/// Release never reads them.
enum ScreenshotSeed {
    static var isOn: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-uiTestSeed")
        #else
        false
        #endif
    }

    static func value(after flag: String) -> String? {
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
        #else
        nil
        #endif
    }

    #if DEBUG
    static var spanish: Bool { Locale.preferredLanguages.first?.hasPrefix("es") == true }

    /// The class the screenshots open: the default one, renamed for the shot.
    static func prepare(_ library: ClassLibraryStore) -> ClassFile? {
        let name = spanish ? "Biología · 3er periodo" : "Biology · Period 3"
        if let existing = library.classes.first(where: { $0.name == name }) { return existing }
        if let first = library.classes.first { _ = library.rename(first, to: name) }
        return library.classes.first(where: { $0.name == name }) ?? library.classes.first
    }

    static func fill(_ store: ClassStore) {
        // Groups and the picked student live only for one launch, so every screenshot launch
        // makes them again; the roster, activities and grades are seeded once.
        defer {
            if store.groups.isEmpty { _ = store.generateGroups(count: 4) }
            store.pickParticipant()
        }
        guard store.students.isEmpty else { return }
        let names = [("Ava", "Martínez"), ("Ben", "Okafor"), ("Chloe", "Nguyen"), ("Diego", "Herrera"), ("Ella", "Schmidt"),
                     ("Felix", "Romero"), ("Grace", "Kim"), ("Hugo", "Duarte"), ("Isla", "Patel"), ("Jonah", "Reyes"),
                     ("Kai", "Lindqvist"), ("Lena", "Castillo")]
        for (index, name) in names.enumerated() {
            _ = store.addStudent(studentId: String(1001 + index), firstName: name.0, lastName: name.1,
                                 email: "\(name.0.lowercased())@school.example")
        }
        _ = store.generateGroups(count: 3)
        let lab = spanish ? "Práctica 1: densidad" : "Lab 1: Density"
        if store.saveCurrentAssignment(asActivity: lab) {
            for (group, grade) in [(1, 9.5), (2, 8.0), (3, 8.8)] { _ = store.gradeGroup(groupNumber: group, activityName: lab, grade: grade) }
        }
        _ = store.generateGroups(count: 4)
        let quiz = spanish ? "Debate: ecosistemas" : "Debate: Ecosystems"
        if store.saveCurrentAssignment(asActivity: quiz) {
            for (group, grade) in [(1, 7.5), (2, 9.0), (3, 8.2), (4, 8.6)] { _ = store.gradeGroup(groupNumber: group, activityName: quiz, grade: grade) }
        }
        for _ in 0..<14 {
            store.pickParticipant()
            store.recordParticipationForSelectedParticipant()
        }
    }
    #endif
}
