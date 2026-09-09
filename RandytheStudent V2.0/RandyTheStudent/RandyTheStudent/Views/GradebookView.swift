//
//  GradebookView.swift
//  RandyTheStudent
//
//  Container for one class's roster, groups, activities, stats, and
//  participation picker. Replaces the single 1,082-line Classes.swift
//  view controller that manually hid/showed dozens of subviews per
//  screen "mode" — each concern is now its own tab/screen instead.
//

import SwiftUI
import AguaDesign

struct GradebookView: View {
    let classFile: ClassFile
    @State private var store: ClassStore

    init(classFile: ClassFile) {
        self.classFile = classFile
        _store = State(initialValue: ClassStore(fileName: classFile.databaseFileName))
    }

    @State private var tempTab = 0 // TEMP: revert before shipping

    var body: some View {
        TabView(selection: $tempTab) {
            RosterView(store: store)
                .tabItem { Label("Roster", systemImage: "person.3") }
                .tag(0)

            GroupsView(store: store)
                .tabItem { Label("Groups", systemImage: "person.2.badge.gearshape") }
                .tag(1)

            ActivitiesView(store: store)
                .tabItem { Label("Activities", systemImage: "checkmark.circle") }
                .tag(2)

            StatsView(store: store)
                .tabItem { Label("Stats", systemImage: "chart.bar") }
                .tag(3)

            ParticipationPickerView(store: store)
                .tabItem { Label("Participation", systemImage: "shuffle") }
                .tag(4)
        }
        .task { // TEMP: revert before shipping
            if store.students.isEmpty {
                store.addStudent(studentId: "T1", firstName: "Alice", lastName: "A", email: "a@test.com")
                store.addStudent(studentId: "T2", firstName: "Bob", lastName: "B", email: "b@test.com")
                store.addStudent(studentId: "T3", firstName: "Carol", lastName: "C", email: "c@test.com")
                for _ in 0..<8 {
                    store.pickParticipant()
                    store.recordParticipationForSelectedParticipant()
                }
                store.generateGroups(count: 2)
                store.saveCurrentAssignment(asActivity: "Quiz A")
                store.gradeGroup(groupNumber: 1, activityName: "Quiz A", grade: 9)
                store.gradeGroup(groupNumber: 2, activityName: "Quiz A", grade: 6)
                store.generateGroups(count: 2)
                store.saveCurrentAssignment(asActivity: "Quiz B")
                store.gradeGroup(groupNumber: 1, activityName: "Quiz B", grade: 7)
                store.gradeGroup(groupNumber: 2, activityName: "Quiz B", grade: 8)
            }
            tempTab = 3
        }
        .tint(AguaColor.Accent.blue)
        .navigationTitle(classFile.name)
        .alert("Something Went Wrong", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { isPresented in if !isPresented { store.clearError() } }
        )) {
            Button("OK") { store.clearError() }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }
}
