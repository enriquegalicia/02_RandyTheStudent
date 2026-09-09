//
//  GroupTypes.swift
//  RandyTheStudent
//

import Foundation

struct GroupMember: Identifiable, Hashable {
    var id: UUID
    var studentId: String
    var studentName: String
    var role: String
    /// How many times this student has previously held this exact role,
    /// not counting the assignment currently on screen (0 the first time).
    var priorRoleCount: Int
}

struct StudentGroup: Identifiable, Hashable {
    /// 1-based group number ("G1", "G2", ...).
    var number: Int
    var members: [GroupMember]

    var id: Int { number }
    var label: String { String(localized: "Group \(number)") }
}
