//
//  StatsView.swift
//  RandyTheStudent
//
//  Two stacked-bar charts: grades by activity, and grades by student.
//  Replaces the hand-rolled pixel-drawing in the old InfoCharts.swift
//  with native Swift Charts, which comes with Dynamic Type, dark mode,
//  and VoiceOver support built in.
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
                    let charts = data
                    if charts.activities.isEmpty && charts.students.isEmpty {
                        ContentUnavailableView(
                            "No Grades Yet",
                            systemImage: "chart.bar",
                            description: Text("Save an activity and grade a group to see stats here.")
                        )
                        .padding(.top, AguaSpacing.xl)
                    } else {
                        chartSection(title: "Grades by Activity", breakdowns: charts.activities.map { ($0.activityName, $0.segments) })
                        chartSection(title: "Grades by Student", breakdowns: charts.students.map { ($0.studentName, $0.segments) })
                    }
                }
                .padding(AguaSpacing.m)
            }
            .aguaBackground()
        }
    }

    @ViewBuilder
    private func chartSection(title: String, breakdowns: [(String, [GradeSegment])]) -> some View {
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
