//
//  ClassStore.swift
//  RandyTheStudent
//
//  Model layer for a single class — roster, random groups, activity
//  grading, participation, and chart data. Replaces Classes.swift.
//
//  The group-balancing algorithm (`generateGroups`) is a faithful,
//  close-to-literal port of the original "randear" (see the old
//  Classes.swift's own header comment calling it "the highest-risk part
//  of this whole migration"). Two pre-existing quirks in that original
//  algorithm are intentionally preserved rather than "fixed" here — see
//  the inline notes at each site — because silently changing which
//  students land in which group is worse than keeping a known quirk.
//

import Foundation
import Observation

@Observable
final class ClassStore {
    private(set) var students: [Student] = []
    private(set) var groups: [StudentGroup] = []
    private(set) var activityGrades: [ActivityGrade] = []
    private(set) var selectedParticipant: Student?
    private(set) var errorMessage: String?

    private let db: SQLiteConnection
    private var slots: [(group: Int, role: String)] = []
    private var payload: [MemberPayload] = []
    private var roleHistorySnapshot: [String: [String: Int]] = [:]

    private struct MemberPayload {
        /// Stable across reorders, so SwiftUI animates the row that's actually
        /// moving rather than treating each slot's contents as swapping in place.
        var id = UUID()
        var studentId: String
        var studentName: String
        var priorRoleCount: Int
    }

    private struct RawGroupRow {
        let group: String
        let studentId: String
        let activity: String
        let role: String
        let grade: Double
    }

    init(fileName: String) {
        db = SQLiteConnection(fileName: fileName)
        do {
            try db.createTableIfNeeded(table: "ESTUDIANTES", columns: [
                (name: "STUDENTID", type: "TEXT"),
                (name: "NOMBRE", type: "TEXT"),
                (name: "APELLIDO", type: "TEXT"),
                (name: "EMAIL", type: "TEXT"),
                (name: "PARTICIPACIONES", type: "FLOAT"),
            ])
            try db.createTableIfNeeded(table: "GRUPOS", columns: [
                (name: "GRUPONO", type: "TEXT"),
                (name: "ALUMNOSID", type: "TEXT"),
                (name: "ACTIVIDAD", type: "TEXT"),
                (name: "POSICION", type: "TEXT"),
                (name: "CALIFICACION", type: "FLOAT"),
            ])
            try reloadStudents()
            try reloadActivities()
        } catch {
            errorMessage = String(localized: "Couldn't open this class.")
        }
    }

    func clearError() {
        errorMessage = nil
    }

    // MARK: - Roster

    func reloadStudents() throws {
        let rows = try db.query(
            "SELECT ID, STUDENTID, NOMBRE, APELLIDO, EMAIL, PARTICIPACIONES FROM ESTUDIANTES",
            columnCount: 6
        )
        students = rows.compactMap { row in
            guard let id = Int(row[0]) else { return nil }
            return Student(id: id, studentId: row[1], firstName: row[2], lastName: row[3], email: row[4], participations: Double(row[5]) ?? 0)
        }
    }

    @discardableResult
    func addStudent(studentId: String, firstName: String, lastName: String, email: String) -> Bool {
        let studentId = studentId.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !studentId.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            errorMessage = String(localized: "Fill in every field before saving.")
            return false
        }
        guard !students.contains(where: { $0.studentId == studentId }) else {
            errorMessage = String(localized: "A student with ID \"\(studentId)\" already exists. Use Modify instead.")
            return false
        }
        do {
            try db.run(
                "INSERT INTO ESTUDIANTES(STUDENTID, NOMBRE, APELLIDO, EMAIL, PARTICIPACIONES) VALUES (?, ?, ?, ?, ?)",
                params: [.text(studentId), .text(firstName), .text(lastName), .text(email), .double(0)]
            )
            try reloadStudents()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't save the student. Try again.")
            return false
        }
    }

    @discardableResult
    func updateStudent(studentId: String, firstName: String, lastName: String, email: String) -> Bool {
        let studentId = studentId.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !studentId.isEmpty, !firstName.isEmpty, !lastName.isEmpty, !email.isEmpty else {
            errorMessage = String(localized: "Fill in every field before saving.")
            return false
        }
        guard students.contains(where: { $0.studentId == studentId }) else {
            errorMessage = String(localized: "No student with ID \"\(studentId)\" was found.")
            return false
        }
        do {
            try db.run(
                "UPDATE ESTUDIANTES SET NOMBRE = ?, APELLIDO = ?, EMAIL = ? WHERE STUDENTID = ?",
                params: [.text(firstName), .text(lastName), .text(email), .text(studentId)]
            )
            try reloadStudents()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't update the student. Try again.")
            return false
        }
    }

    @discardableResult
    func deleteStudent(studentId: String) -> Bool {
        do {
            try db.run("DELETE FROM ESTUDIANTES WHERE STUDENTID = ?", params: [.text(studentId)])
            try reloadStudents()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't delete the student. Try again.")
            return false
        }
    }

    // MARK: - Participation

    func pickParticipant() {
        guard !students.isEmpty else {
            selectedParticipant = nil
            return
        }
        let maxParticipations = students.map(\.participations).max() ?? 0
        let candidates: [Student]
        if maxParticipations == 0 {
            candidates = students
        } else {
            let below = students.filter { $0.participations < maxParticipations }
            candidates = below.isEmpty ? students.filter { $0.participations == maxParticipations } : below
        }
        selectedParticipant = shuffledThreeTimes(candidates).first
    }

    @discardableResult
    func recordParticipationForSelectedParticipant() -> Bool {
        guard let participant = selectedParticipant else { return false }
        do {
            try db.run(
                "UPDATE ESTUDIANTES SET PARTICIPACIONES = ? WHERE ID = ?",
                params: [.double(participant.participations + 1), .double(Double(participant.id))]
            )
            try reloadStudents()
            selectedParticipant = students.first(where: { $0.id == participant.id })
            return true
        } catch {
            errorMessage = String(localized: "Couldn't record participation. Try again.")
            return false
        }
    }

    private func shuffledOnce<T>(_ array: [T]) -> [T] {
        var result: [T] = []
        for item in array {
            result.insert(item, at: Int.random(in: 0...result.count))
        }
        return result
    }

    private func shuffledThreeTimes<T>(_ array: [T]) -> [T] {
        shuffledOnce(shuffledOnce(shuffledOnce(array)))
    }

    // MARK: - Groups

    private func fetchRawGroupRows() throws -> [RawGroupRow] {
        let rows = try db.query("SELECT GRUPONO, ALUMNOSID, ACTIVIDAD, POSICION, CALIFICACION FROM GRUPOS", columnCount: 5)
        return rows.map { RawGroupRow(group: $0[0], studentId: $0[1], activity: $0[2], role: $0[3], grade: Double($0[4]) ?? 0) }
    }

    private func studentName(for studentId: String) -> String {
        students.first(where: { $0.studentId == studentId })?.fullName ?? studentId
    }

    @discardableResult
    func generateGroups(count requestedCount: Int) -> Bool {
        guard requestedCount >= 1 else { return false }
        do {
            let historyRows = try fetchRawGroupRows()

            var studentTotals: [String: Double] = [:]
            for row in historyRows { studentTotals[row.studentId, default: 0] += row.grade }
            let distinctGrades = Set(historyRows.map(\.grade))
            let hasAntecedents = !studentTotals.isEmpty && distinctGrades.count > 1

            var groupHistory: [String: [String: Int]] = [:]
            var roleHistory: [String: [String: Int]] = [:]
            for row in historyRows {
                groupHistory[row.studentId, default: [:]][row.group, default: 0] += 1
                roleHistory[row.studentId, default: [:]][row.role, default: 0] += 1
            }
            roleHistorySnapshot = roleHistory

            var newSlots: [(group: Int, role: String)] = []
            var newPayload: [MemberPayload] = []

            if hasAntecedents {
                let rankedIds = studentTotals.keys.sorted { studentTotals[$0]! > studentTotals[$1]! }

                if requestedCount == 1 {
                    // The original algorithm builds an equivalent single-group bucket via
                    // the top/bottom draft below, but that work is never read afterwards
                    // for the entero==1 case — the real output there is just the full
                    // ranked roster assigned straight to G1. Reproduced directly.
                    for (index, studentId) in rankedIds.enumerated() {
                        let role = "Rol \(index + 1)"
                        newSlots.append((group: 1, role: role))
                        newPayload.append(MemberPayload(studentId: studentId, studentName: studentName(for: studentId), priorRoleCount: roleHistory[studentId]?[role] ?? 0))
                    }
                } else {
                    var buckets: [[String]] = Array(repeating: [], count: requestedCount)
                    var remaining = rankedIds
                    let total = Double(rankedIds.count)
                    let groupCountF = Double(requestedCount)
                    let averageSize = total / groupCountF

                    func placeFront() {
                        for g in 0..<requestedCount where !remaining.isEmpty {
                            buckets[g].append(remaining.removeFirst())
                        }
                    }
                    func placeBack() {
                        for g in 0..<requestedCount where !remaining.isEmpty {
                            buckets[g].append(remaining.removeLast())
                        }
                    }

                    if averageSize >= 2 {
                        placeFront()
                        placeBack()
                        let extraRounds = Int((total - (groupCountF * 2)) / (groupCountF * 2))
                        if extraRounds > 0 {
                            for _ in 0..<extraRounds {
                                placeFront()
                                placeBack()
                            }
                        }
                    }
                    if Double(remaining.count) >= groupCountF {
                        placeFront()
                    }
                    // NOTE: the original also has a "leftover distribution" step for
                    // students still left in `remaining` at this point, meant to spread
                    // them across the groups closest to the average size. Its threshold
                    // computation is `Int(division)*(g+1) - Int(division)*(g+1)`, which is
                    // always zero — so in the shipped app that step never actually places
                    // anyone, and any true remainder is silently left ungrouped. Preserved
                    // by simply not implementing that dead step, matching live behavior.

                    // Order buckets into G1...G{n}, minimizing each bucket's combined
                    // history with that group label. Ported verbatim, including the
                    // original's "maximo == 0" sentinel: when multiple buckets tie at
                    // zero prior history with a label (the common case), the *last* such
                    // bucket wins, not the first — a pre-existing quirk, kept as-is.
                    var pool = buckets
                    var ordered: [[String]] = []
                    for slotIndex in 0..<requestedCount {
                        let label = "G\(slotIndex + 1)"
                        var maximo = 0
                        var chosen = 0
                        for (j, bucket) in pool.enumerated() {
                            let sum = bucket.reduce(0) { $0 + (groupHistory[$1]?[label] ?? 0) }
                            if maximo == 0 {
                                maximo = sum
                                chosen = j
                            } else if maximo > sum {
                                maximo = sum
                                chosen = j
                            }
                        }
                        ordered.append(pool[chosen])
                        pool.remove(at: chosen)
                    }

                    for (groupIndex, bucket) in ordered.enumerated() {
                        var candidates = bucket
                        for roleIndex in 0..<bucket.count {
                            let role = "Rol \(roleIndex + 1)"
                            var maximo = 0
                            var chosen = 0
                            for (n, studentId) in candidates.enumerated() {
                                let count = roleHistory[studentId]?[role] ?? 0
                                if maximo == 0 {
                                    maximo = count
                                    chosen = n
                                } else if maximo > count {
                                    maximo = count
                                    chosen = n
                                }
                            }
                            let studentId = candidates.remove(at: chosen)
                            newSlots.append((group: groupIndex + 1, role: role))
                            newPayload.append(MemberPayload(studentId: studentId, studentName: studentName(for: studentId), priorRoleCount: roleHistory[studentId]?[role] ?? 0))
                        }
                    }
                }
            } else if !students.isEmpty {
                // No grading history yet: distribute a plain shuffle into equal-ish
                // contiguous chunks. Same floor-based chunk boundaries as the original,
                // including the fact that they can drop the last student or two when the
                // roster doesn't divide evenly by the group count (e.g. 10 students into
                // 3 groups drops 1) — a pre-existing quirk, kept as-is rather than
                // "corrected" into different group membership than before.
                let shuffledStudents = shuffledOnce(shuffledOnce(students))
                let total = Double(shuffledStudents.count)
                let groupCountF = Double(requestedCount)
                let averageSize = total / groupCountF
                for g in 0..<requestedCount {
                    let start = Int(averageSize * Double(g))
                    let end = Int(averageSize * Double(g + 1)) - 1
                    guard start <= end else { continue }
                    var roleIndex = 0
                    for i in start...end where i < shuffledStudents.count {
                        let student = shuffledStudents[i]
                        let role = "Rol \(roleIndex + 1)"
                        newSlots.append((group: g + 1, role: role))
                        newPayload.append(MemberPayload(studentId: student.studentId, studentName: student.fullName, priorRoleCount: roleHistory[student.studentId]?[role] ?? 0))
                        roleIndex += 1
                    }
                }
            }

            slots = newSlots
            payload = newPayload
            rebuildGroups()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't generate groups. Try again.")
            return false
        }
    }

    private func rebuildGroups() {
        var byGroup: [Int: [GroupMember]] = [:]
        for (index, slot) in slots.enumerated() {
            let member = payload[index]
            let groupMember = GroupMember(id: member.id, studentId: member.studentId, studentName: member.studentName, role: slot.role, priorRoleCount: member.priorRoleCount)
            byGroup[slot.group, default: []].append(groupMember)
        }
        groups = byGroup.keys.sorted().map { StudentGroup(number: $0, members: byGroup[$0] ?? []) }
    }

    /// Lets a teacher manually swap two students' slots after generation
    /// (a modern, drag-to-reorder equivalent of the original's tap-a-row-then-
    /// press-Up/Down flow) — the group/role a slot represents stays fixed;
    /// only which student occupies it moves.
    func moveMember(from source: IndexSet, to destination: Int) {
        var updated = payload
        let itemsToMove = source.map { updated[$0] }
        for index in source.sorted(by: >) {
            updated.remove(at: index)
        }
        let adjustedDestination = destination - source.filter { $0 < destination }.count
        updated.insert(contentsOf: itemsToMove, at: min(max(adjustedDestination, 0), updated.count))
        for index in updated.indices {
            let role = slots[index].role
            updated[index].priorRoleCount = roleHistorySnapshot[updated[index].studentId]?[role] ?? 0
        }
        payload = updated
        rebuildGroups()
    }

    // MARK: - Activities

    func reloadActivities() throws {
        let rows = try fetchRawGroupRows()
        var seen = Set<String>()
        var result: [ActivityGrade] = []
        for row in rows.sorted(by: { $0.activity == $1.activity ? $0.group < $1.group : $0.activity < $1.activity }) {
            let key = "\(row.group)|\(row.activity)"
            guard !seen.contains(key), let groupNumber = Int(row.group.dropFirst()) else { continue }
            seen.insert(key)
            result.append(ActivityGrade(groupNumber: groupNumber, activityName: row.activity, grade: row.grade))
        }
        activityGrades = result
    }

    @discardableResult
    func saveCurrentAssignment(asActivity name: String) -> Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !payload.isEmpty else { return false }
        do {
            let existingStudentIds = Set(try fetchRawGroupRows().filter { $0.activity == name }.map(\.studentId))
            for (index, member) in payload.enumerated() {
                guard !existingStudentIds.contains(member.studentId) else { continue }
                let slot = slots[index]
                try db.run(
                    "INSERT INTO GRUPOS(GRUPONO, ALUMNOSID, ACTIVIDAD, POSICION, CALIFICACION) VALUES (?, ?, ?, ?, ?)",
                    params: [.text("G\(slot.group)"), .text(member.studentId), .text(name), .text(slot.role), .double(0)]
                )
            }
            try reloadActivities()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't save the activity. Try again.")
            return false
        }
    }

    @discardableResult
    func deleteActivity(named name: String) -> Bool {
        do {
            try db.run("DELETE FROM GRUPOS WHERE ACTIVIDAD = ?", params: [.text(name)])
            try reloadActivities()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't delete the activity. Try again.")
            return false
        }
    }

    @discardableResult
    func gradeGroup(groupNumber: Int, activityName: String, grade: Double) -> Bool {
        do {
            try db.run(
                "UPDATE GRUPOS SET CALIFICACION = ? WHERE GRUPONO = ? AND ACTIVIDAD = ?",
                params: [.double(grade), .text("G\(groupNumber)"), .text(activityName)]
            )
            try reloadActivities()
            return true
        } catch {
            errorMessage = String(localized: "Couldn't save the grade. Try again.")
            return false
        }
    }

    // MARK: - Stats

    func chartData() -> (activities: [ActivityBreakdown], students: [StudentBreakdown]) {
        guard let rows = try? fetchRawGroupRows() else { return ([], []) }

        let activityNames = Set(rows.map(\.activity)).sorted()
        let activityBreakdowns = activityNames.map { activity -> ActivityBreakdown in
            let segments = rows.filter { $0.activity == activity }.map {
                GradeSegment(label: studentName(for: $0.studentId), value: $0.grade)
            }
            return ActivityBreakdown(activityName: activity, segments: segments)
        }

        var totals: [String: Double] = [:]
        for row in rows { totals[row.studentId, default: 0] += row.grade }
        let orderedIds = totals.keys.sorted { totals[$0]! > totals[$1]! }
        let studentBreakdowns = orderedIds.map { studentId -> StudentBreakdown in
            var byRole: [String: Double] = [:]
            for row in rows where row.studentId == studentId {
                byRole[row.role, default: 0] += row.grade
            }
            let segments = byRole.keys.sorted().map { GradeSegment(label: $0, value: byRole[$0]!) }
            return StudentBreakdown(studentId: studentId, studentName: studentName(for: studentId), segments: segments)
        }
        return (activityBreakdowns, studentBreakdowns)
    }
}
