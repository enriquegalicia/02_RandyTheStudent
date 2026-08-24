//
//  ActivityTypes.swift
//  RandyTheStudent
//

import Foundation

struct ActivityGrade: Identifiable, Hashable {
    var groupNumber: Int
    var activityName: String
    var grade: Double

    var id: String { "\(activityName)-G\(groupNumber)" }
    var groupLabel: String { "Group \(groupNumber)" }
}

/// One colored segment of a stacked bar in the stats charts.
struct GradeSegment: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var value: Double
}

/// Chart 1: one stacked bar per activity, segmented by each student's grade
/// contribution to that activity.
struct ActivityBreakdown: Identifiable, Hashable {
    var activityName: String
    var segments: [GradeSegment]
    var id: String { activityName }
}

/// Chart 2: one stacked bar per student (ranked by total grade, highest
/// first), segmented by grade contribution per role they've held.
struct StudentBreakdown: Identifiable, Hashable {
    var studentId: String
    var studentName: String
    var segments: [GradeSegment]
    var id: String { studentId }
}
