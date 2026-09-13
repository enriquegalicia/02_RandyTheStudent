//
//  CSVSupport.swift
//  RandyTheStudent
//
//  RFC4180-ish CSV parsing/writing, plus the specific roster/groups export
//  and roster import formats. The parser is intentionally hand-rolled and
//  was validated against a standalone test suite (quoted fields, embedded
//  commas/quotes/newlines, CRLF vs LF vs lone-CR line endings, round-trip
//  escape+parse) before landing here — CRLF handling in particular has a
//  real gotcha: `Array(text)` gives `[Character]` (extended grapheme
//  clusters), and Swift's `Character` treats "\r\n" as ONE grapheme
//  cluster that never equals standalone "\r" or "\n" — so a naive
//  case-per-line-ending switch silently fails on exactly the line endings
//  Excel/Numbers actually produce. See the explicit "\r\n" case below.
//
//  Column headers in the CSV files themselves (StudentID, FirstName, ...)
//  are deliberately NOT localized — they're a data interchange contract
//  (like a JSON key), not UI chrome, and keeping them fixed means a CSV
//  exported from a Spanish-language iPad still imports correctly on an
//  English-language one, and vice versa.
//

import Foundation

enum CSV {
    /// Parses CSV text into rows of fields. Blank lines are dropped.
    static func parse(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var insideQuotes = false
        var sawAnyContentInRow = false

        let chars = Array(text)
        var i = 0
        while i < chars.count {
            let c = chars[i]
            if insideQuotes {
                if c == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 1
                    } else {
                        insideQuotes = false
                    }
                } else {
                    currentField.append(c)
                }
            } else {
                switch c {
                case "\"":
                    insideQuotes = true
                    sawAnyContentInRow = true
                case ",":
                    currentRow.append(currentField)
                    currentField = ""
                    sawAnyContentInRow = true
                case "\r\n", "\n", "\r":
                    currentRow.append(currentField)
                    currentField = ""
                    if sawAnyContentInRow || currentRow.count > 1 || !(currentRow.first ?? "").isEmpty {
                        rows.append(currentRow)
                    }
                    currentRow = []
                    sawAnyContentInRow = false
                default:
                    currentField.append(c)
                    sawAnyContentInRow = true
                }
            }
            i += 1
        }
        // Flush whatever's left after the loop (file with no trailing newline).
        if sawAnyContentInRow || !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            if sawAnyContentInRow || currentRow.count > 1 || !(currentRow.first ?? "").isEmpty {
                rows.append(currentRow)
            }
        }
        return rows
    }

    static func escapeField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") || field.contains("\r") {
            return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return field
    }

    static func line(_ fields: [String]) -> String {
        fields.map(escapeField).joined(separator: ",")
    }

    /// Tries UTF-8 first (what this app writes, and what most modern export
    /// flows use), then a couple of common legacy encodings — an older
    /// Windows Excel saving accented Spanish names as Latin-1/CP1252 is a
    /// real scenario, not a hypothetical one, given who this app is for.
    static func readText(at url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        for encoding: String.Encoding in [.utf8, .isoLatin1, .windowsCP1252] {
            if let text = String(data: data, encoding: encoding) {
                return text
            }
        }
        return nil
    }

    /// Writes text to a fresh temp file with the given name, for handing to
    /// a share sheet — a real file (not raw text/Data) is what makes
    /// AirDrop/Mail/Files see an actual named ".csv" that opens correctly
    /// in a spreadsheet app, instead of a lump of plain text.
    static func writeTempFile(_ text: String, named filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}

enum RosterCSV {
    static let header = ["StudentID", "FirstName", "LastName", "Email"]

    struct Row {
        var studentId: String
        var firstName: String
        var lastName: String
        var email: String
    }

    static func exportText(students: [Student]) -> String {
        var lines = [CSV.line(header)]
        for student in students.sorted(by: { $0.lastName < $1.lastName }) {
            lines.append(CSV.line([student.studentId, student.firstName, student.lastName, student.email]))
        }
        return lines.joined(separator: "\n") + "\n"
    }

    /// One filled-in example row alongside the header, so opening the
    /// template shows exactly what's expected instead of just column names.
    static var templateText: String {
        exportText(students: [
            Student(id: 0, studentId: "S001", firstName: "Ana", lastName: "García López", email: "ana@example.com"),
        ])
    }

    /// Skips a leading header row if present (matched by column 0 against
    /// "StudentID", case-insensitively — the file this app exports always
    /// has one, but a hand-built CSV might not).
    static func parseRows(_ text: String) -> [Row] {
        var rows = CSV.parse(text)
        if let first = rows.first, let firstCell = first.first, firstCell.caseInsensitiveCompare("StudentID") == .orderedSame {
            rows.removeFirst()
        }
        return rows.compactMap { fields in
            guard fields.count >= 4 else { return nil }
            return Row(studentId: fields[0], firstName: fields[1], lastName: fields[2], email: fields[3])
        }
    }
}

enum GroupsCSV {
    static let header = ["Group", "Role", "StudentID", "StudentName"]

    static func exportText(groups: [StudentGroup]) -> String {
        var lines = [CSV.line(header)]
        for group in groups.sorted(by: { $0.number < $1.number }) {
            for member in group.members {
                lines.append(CSV.line(["G\(group.number)", ClassStore.displayRole(member.role), member.studentId, member.studentName]))
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }
}
