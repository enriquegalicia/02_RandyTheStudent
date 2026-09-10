//
//  RootView.swift
//  RandyTheStudent
//
//  NavigationSplitView self-adapts between an iPad sidebar+detail layout
//  and a stacked iPhone layout from a single view tree — this is what
//  replaces the old app's five separate `UIDevice.userInterfaceIdiom ==
//  .phone` branches (and the two entirely different XIBs per screen).
//

import SwiftUI
import AguaDesign

struct RootView: View {
    @State private var library = ClassLibraryStore()
    @State private var selectedClass: ClassFile?
    @State private var showingCredits = false
    @State private var showingSettings = false

    var body: some View {
        NavigationSplitView {
            ClassLibraryView(library: library, selectedClass: $selectedClass, showingCredits: $showingCredits, showingSettings: $showingSettings)
        } detail: {
            if let selectedClass {
                GradebookView(classFile: selectedClass)
                    .id(selectedClass.id)
            } else {
                ContentUnavailableView(
                    "Select a Class",
                    systemImage: "person.3.sequence",
                    description: Text("Choose a class on the left, or create a new one to get started.")
                )
                .aguaBackground()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingCredits) {
            CreditsView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    RootView()
}
