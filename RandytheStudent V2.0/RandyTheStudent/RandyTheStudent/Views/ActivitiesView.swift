//
//  ActivitiesView.swift
//  RandyTheStudent
//
//  Grade each group's performance on a saved activity, or remove an
//  activity entirely. Replaces the "Grupo" control group from the old
//  Classes.swift.
//

import SwiftUI
import AguaDesign

struct ActivitiesView: View {
    var store: ClassStore

    @State private var gradeDrafts: [String: String] = [:]
    @State private var activityPendingDeletion: String?
    @State private var showingAddActivity = false
    @State private var showingNoGroupsYet = false
    @State private var newActivityName = ""

    private var groupedByActivity: [(name: String, grades: [ActivityGrade])] {
        Dictionary(grouping: store.activityGrades, by: \.activityName)
            .map { (name: $0.key, grades: $0.value.sorted { $0.groupNumber < $1.groupNumber }) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                if groupedByActivity.isEmpty {
                    ContentUnavailableView(
                        "No Activities Yet",
                        systemImage: "checkmark.circle",
                        description: Text("Generate groups, then save them as an activity to start grading.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(groupedByActivity, id: \.name) { activity in
                        Section {
                            ForEach(activity.grades) { grade in
                                HStack {
                                    Text(grade.groupLabel)
                                        .foregroundStyle(AguaColor.textPrimary)
                                    Spacer()
                                    TextField(
                                        "Grade",
                                        text: Binding(
                                            get: { gradeDrafts[grade.id] ?? formatted(grade.grade) },
                                            set: { gradeDrafts[grade.id] = $0 }
                                        )
                                    )
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .textFieldStyle(.roundedBorder)
                                    .onSubmit { save(grade) }
                                    Button("Save") { save(grade) }
                                        .buttonStyle(.bordered)
                                }
                            }
                        } header: {
                            AguaGroupHeader(activity.name)
                        }
                        .listRowBackground(AguaColor.bgCard)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                activityPendingDeletion = activity.name
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .aguaBackground()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if store.groups.isEmpty {
                            showingNoGroupsYet = true
                        } else {
                            newActivityName = ""
                            showingAddActivity = true
                        }
                    } label: {
                        Label("Add Activity", systemImage: "plus")
                    }
                }
            }
        }
        .alert("New Activity", isPresented: $showingAddActivity) {
            TextField("Activity name", text: $newActivityName)
            Button("Save") {
                store.saveCurrentAssignment(asActivity: newActivityName)
                newActivityName = ""
            }
            .disabled(newActivityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Saves the groups you generated in the Groups tab under this name.")
        }
        .alert("No Groups Yet", isPresented: $showingNoGroupsYet) {
            Button("OK") {}
        } message: {
            Text("Generate groups in the Groups tab first, then come back here to save them as an activity.")
        }
        .confirmationDialog(
            "Delete this activity for every group?",
            isPresented: Binding(
                get: { activityPendingDeletion != nil },
                set: { isPresented in if !isPresented { activityPendingDeletion = nil } }
            ),
            titleVisibility: .visible,
            presenting: activityPendingDeletion
        ) { name in
            Button("Delete \"\(name)\"", role: .destructive) {
                store.deleteActivity(named: name)
                activityPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) { activityPendingDeletion = nil }
        }
    }

    private func save(_ grade: ActivityGrade) {
        let text = gradeDrafts[grade.id] ?? formatted(grade.grade)
        guard let value = Double(text) else { return }
        store.gradeGroup(groupNumber: grade.groupNumber, activityName: grade.activityName, grade: value)
        gradeDrafts[grade.id] = nil
    }

    private func formatted(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
}
