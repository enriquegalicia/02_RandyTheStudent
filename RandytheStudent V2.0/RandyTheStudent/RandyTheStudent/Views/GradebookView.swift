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

    var body: some View {
        TabView {
            RosterView(store: store, className: classFile.name)
                .tabItem { Label("Roster", systemImage: "person.3") }

            GroupsView(store: store, className: classFile.name)
                .tabItem { Label("Groups", systemImage: "person.2.badge.gearshape") }

            ActivitiesView(store: store)
                .tabItem { Label("Activities", systemImage: "checkmark.circle") }

            StatsView(store: store)
                .tabItem { Label("Stats", systemImage: "chart.bar") }

            ParticipationPickerView(store: store)
                .tabItem { Label("Participation", systemImage: "shuffle") }
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
