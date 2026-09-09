//
//  StatsView.swift
//  RandyTheStudent
//
//  Participation ranking (most/least active), grades by activity (grouped
//  by group, with each activity's average called out), and grades by
//  student. Replaces the hand-rolled pixel-drawing in the old
//  InfoCharts.swift with native Swift Charts, which comes with Dynamic
//  Type, dark mode, and VoiceOver support built in.
//

import SwiftUI
import Charts
import AguaDesign

struct StatsView: View {
    var store: ClassStore

    private var data: (activities: [ActivityBreakdown], students: [StudentBreakdown]) {
        store.chartData()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AguaSpacing.l) {
                    if store.students.isEmpty {
                        ContentUnavailableView(
                            "No Data Yet",
                            systemImage: "chart.bar",
                            description: Text("Add students to the roster to see stats here.")
                        )
                        .padding(.top, AguaSpacing.xl)
                    } else {
                        participationSection

                        let charts = data
                        if charts.activities.isEmpty && charts.students.isEmpty {
                            ContentUnavailableView(
                                "No Grades Yet",
                                systemImage: "chart.bar",
                                description: Text("Save an activity and grade a group to see stats here.")
                            )
                        } else {
                            activityChartSection(activities: charts.activities)
                            chartSection(title: "Grades by Student", breakdowns: charts.students.map { ($0.studentName, $0.segments) })
                        }
                    }
                }
                .padding(AguaSpacing.m)
            }
            .aguaBackground()
        }
    }

    // MARK: - Participation

    private var participationSection: some View {
        let ranking = store.participationRanking()
        return VStack(alignment: .leading, spacing: AguaSpacing.s) {
            AguaGroupHeader(String(localized: "Participation"))
            HStack(alignment: .top, spacing: AguaSpacing.m) {
                participationList(
                    title: String(localized: "Most Active"),
                    icon: "star.fill",
                    tint: AguaColor.Accent.blue,
                    students: ranking.mostActive
                )
                participationList(
                    title: String(localized: "Needs Attention"),
                    icon: "exclamationmark.triangle.fill",
                    tint: .orange,
                    students: ranking.leastActive
                )
            }
        }
        .padding(AguaSpacing.m)
        .aguaCard()
    }

    @ViewBuilder
    private func participationList(title: String, icon: String, tint: Color, students: [Student]) -> some View {
        VStack(alignment: .leading, spacing: AguaSpacing.xs) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(tint)

            if students.isEmpty {
                Text("—")
                    .font(.caption)
                    .foregroundStyle(AguaColor.textMuted)
            } else {
                ForEach(Array(students.enumerated()), id: \.element.id) { index, student in
                    HStack(spacing: 4) {
                        Text("\(index + 1).")
                            .foregroundStyle(AguaColor.textMuted)
                        Text(student.fullName)
                            .foregroundStyle(AguaColor.textPrimary)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text("\(Int(student.participations))")
                            .foregroundStyle(AguaColor.textMuted)
                    }
                    .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Charts

    @ViewBuilder
    private func activityChartSection(activities: [ActivityBreakdown]) -> some View {
        if !activities.isEmpty {
            VStack(alignment: .leading, spacing: AguaSpacing.s) {
                AguaGroupHeader(String(localized: "Grades by Activity"))
                Chart {
                    ForEach(activities) { activity in
                        ForEach(activity.segments) { segment in
                            BarMark(
                                x: .value("Grade", segment.value),
                                y: .value("Activity", activity.activityName)
                            )
                            .foregroundStyle(by: .value("Group", segment.label))
                            .position(by: .value("Group", segment.label))
                        }
                        PointMark(
                            x: .value("Average", activity.average),
                            y: .value("Activity", activity.activityName)
                        )
                        .foregroundStyle(AguaColor.textPrimary)
                        .symbol(.diamond)
                        .symbolSize(90)
                        .annotation(position: .top) {
                            Text(activity.average.formatted(.number.precision(.fractionLength(0...1))))
                                .font(.caption2.bold())
                                .foregroundStyle(AguaColor.textPrimary)
                        }
                    }
                }
                .frame(height: CGFloat(activities.count) * 64 + 20)

                Label("Diamond marks each activity's average across its groups.", systemImage: "info.circle")
                    .font(.caption2)
                    .foregroundStyle(AguaColor.textMuted)
            }
            .padding(AguaSpacing.m)
            .aguaCard()
        }
    }

    @ViewBuilder
    private func chartSection(title: LocalizedStringKey, breakdowns: [(String, [GradeSegment])]) -> some View {
        if !breakdowns.isEmpty {
            VStack(alignment: .leading, spacing: AguaSpacing.s) {
                AguaGroupHeader(title)
                Chart {
                    ForEach(breakdowns, id: \.0) { row in
                        ForEach(row.1) { segment in
                            BarMark(
                                x: .value("Grade", segment.value),
                                y: .value("Name", row.0)
                            )
                            .foregroundStyle(by: .value("Contributor", segment.label))
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(height: CGFloat(breakdowns.count) * 44 + 20)
            }
            .padding(AguaSpacing.m)
            .aguaCard()
        }
    }
}
