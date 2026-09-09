//
//  ClassLibraryStore.swift
//  RandyTheStudent
//
//  Manages the list of classes (each backed by its own SQLite file) —
//  the model layer behind what used to be RandyMenu.swift.
//

import Foundation
import Observation

@Observable
final class ClassLibraryStore {
    private(set) var classes: [ClassFile] = []
    private(set) var errorMessage: String?

    private let db = SQLiteConnection(fileName: "Principal2.db")

    init() {
        do {
            try db.createTableIfNeeded(table: "ARCHIVOS", columns: [
                (name: "NOMBRE", type: "TEXT"),
                (name: "ARCHITEXT", type: "TEXT"),
            ])
            try ensureDefaultClassExists()
            try reload()
        } catch {
            log("open library", error)
            errorMessage = String(localized: "Couldn't open the class library.")
        }
    }

    private func ensureDefaultClassExists() throws {
        let existing = try db.query("SELECT ID FROM ARCHIVOS", columnCount: 1)
        guard existing.isEmpty else { return }
        try db.run(
            "INSERT INTO ARCHIVOS(NOMBRE, ARCHITEXT) VALUES (?, ?)",
            params: [.text("Default"), .text("Default2.db")]
        )
    }

    func reload() throws {
        let rows = try db.query("SELECT ID, NOMBRE, ARCHITEXT FROM ARCHIVOS", columnCount: 3)
        classes = rows.compactMap { row in
            guard let id = Int(row[0]) else { return nil }
            return ClassFile(id: id, name: row[1], databaseFileName: row[2])
        }
    }

    @discardableResult
    func createClass(named name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !classes.contains(where: { $0.name.caseInsensitiveCompare(trimmed) == .orderedSame }) else {
            errorMessage = String(localized: "A class named \"\(trimmed)\" already exists.")
            return false
        }
        do {
            try db.run(
                "INSERT INTO ARCHIVOS(NOMBRE, ARCHITEXT) VALUES (?, ?)",
                params: [.text(trimmed), .text("\(trimmed).db")]
            )
            try reload()
            return true
        } catch {
            log("create class", error)
            errorMessage = String(localized: "Couldn't create the class. Try again.")
            return false
        }
    }

    @discardableResult
    func rename(_ classFile: ClassFile, to newName: String) -> Bool {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        do {
            try db.run(
                "UPDATE ARCHIVOS SET NOMBRE = ? WHERE ID = ?",
                params: [.text(trimmed), .double(Double(classFile.id))]
            )
            try reload()
            return true
        } catch {
            log("rename class", error)
            errorMessage = String(localized: "Couldn't rename the class. Try again.")
            return false
        }
    }

    @discardableResult
    func delete(_ classFile: ClassFile) -> Bool {
        do {
            try db.run("DELETE FROM ARCHIVOS WHERE ID = ?", params: [.double(Double(classFile.id))])
            try reload()
            return true
        } catch {
            log("delete class", error)
            errorMessage = String(localized: "Couldn't delete the class. Try again.")
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    /// Prints the real underlying error to the console — `errorMessage` is
    /// deliberately generic for the user, but when something fails it's
    /// otherwise invisible what actually went wrong.
    private func log(_ context: String, _ error: Error) {
        print("[ClassLibraryStore] \(context) failed: \(error)")
    }
}
