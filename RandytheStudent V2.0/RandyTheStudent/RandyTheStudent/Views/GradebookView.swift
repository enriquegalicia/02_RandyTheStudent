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
    @State private var tab = ScreenshotSeed.value(after: "-uiTestTab").flatMap(Int.init) ?? 0

    init(classFile: ClassFile) {
        self.classFile = classFile
        _store = State(initialValue: ClassStore(fileName: classFile.databaseFileName))
    }

    var body: some View {
        TabView(selection: $tab) {
            RosterView(store: store, className: classFile.name)
                .tabItem { Label("Roster", systemImage: "person.3") }.tag(0)

            GroupsView(store: store, className: classFile.name)
                .tabItem { Label("Groups", systemImage: "person.2.badge.gearshape") }.tag(1)

            ActivitiesView(store: store)
                .tabItem { Label("Activities", systemImage: "checkmark.circle") }.tag(2)

            StatsView(store: store)
                .tabItem { Label("Stats", systemImage: "chart.bar") }.tag(3)

            ParticipationPickerView(store: store)
                .tabItem { Label("Participation", systemImage: "shuffle") }.tag(4)
        }
        .tint(Color.chalk)
        .navigationTitle(classFile.name)
        #if DEBUG
        .task { if ScreenshotSeed.isOn { ScreenshotSeed.fill(store) } }
        #endif
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
