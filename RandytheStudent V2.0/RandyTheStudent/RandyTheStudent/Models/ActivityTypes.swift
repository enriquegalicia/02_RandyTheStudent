//
//  ActivityTypes.swift
//  RandyTheStudent
//

import Foundation

struct ActivityGrade: Identifiable, Hashable {
    /// 0 is a legitimate grade on any configured scale (see
    /// GradeScaleSettings) — it can't double as "not graded yet" the way it
    /// used to. A negative sentinel (outside every valid range, whatever the
    /// scale) marks a group that hasn't been graded.
    static let ungraded: Double = -1

    var groupNumber: Int
    var activityName: String
    var grade: Double

    var id: String { "\(activityName)-G\(groupNumber)" }
    // String(localized:) rather than a plain interpolated literal: this value
    // flows into `Text(_ content: String)` (the verbatim overload) at the
    // call site, which never does table lookup on its own.
    var groupLabel: String { String(localized: "Group \(groupNumber)") }

    var isGraded: Bool { grade >= 0 }
}

/// One colored segment of a stacked bar in the stats charts.
struct GradeSegment: Identifiable, Hashable {
    var id = UUID()
    var label: String
    var value: Double
}

/// Chart 1: one grouped (dodged, not stacked) bar per activity per group,
/// plus that activity's average across its groups — so it's easy to see
/// which activities scored well overall, not just which group did best.
struct ActivityBreakdown: Identifiable, Hashable {
    var activityName: String
    var average: Double
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
