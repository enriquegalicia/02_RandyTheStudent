//
//  ActivitiesView.swift
//  RandyTheStudent
//
//  Grade each group's performance on a saved activity, or remove an
//  activity entirely. Replaces the "Grupo" control group from the old
//  Classes.swift.
//
//  Ungraded groups (ActivityGrade.isGraded == false) are the default,
//  editable list — the point being to grade what hasn't been graded yet.
//  Already-graded groups are hidden by default (so a full section doesn't
//  fill up with things there's nothing left to do to) and surfaced one at
//  a time through the "Review a graded group" menu, to look at or correct
//  a grade after the fact.
//
//  Saving a grade is a single tap with no confirmation dialog or "Saved"
//  message — grading a whole roster of groups one at a time is exactly
//  the kind of repeated action where a dialog per group is friction, not
//  safety. Errors still surface (via ClassStore.errorMessage, shown by the
//  parent GradebookView) if a save genuinely fails.
//

import SwiftUI
import AguaDesign

struct ActivitiesView: View {
    var store: ClassStore

    // Own reactive copy of the setting (rather than reading
    // GradeScaleSettings.currentMax directly) so this view actually
    // refreshes if the grading scale changes while it's on screen — see
    // GradeScaleSettings' note on why ClassStore doesn't need the same.
    @AppStorage(GradeScaleSettings.userDefaultsKey) private var gradeScaleMax: Double = GradeScaleSettings.defaultMax

    @State private var gradeDrafts: [String: String] = [:]
    @State private var revealedGradedIds: Set<String> = []
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
                        let ungraded = activity.grades.filter { !$0.isGraded }
                        let graded = activity.grades.filter(\.isGraded)
                        let hiddenGraded = graded.filter { !revealedGradedIds.contains($0.id) }

                        Section {
                            if ungraded.isEmpty && graded.allSatisfy({ !revealedGradedIds.contains($0.id) }) {
                                Text("Every group is graded.")
                                    .font(.footnote)
                                    .foregroundStyle(AguaColor.textMuted)
                            }

                            ForEach(ungraded) { grade in
                                gradeRow(grade)
                            }

                            ForEach(graded.filter { revealedGradedIds.contains($0.id) }) { grade in
                                gradeRow(grade, isReviewing: true)
                            }

                            if !hiddenGraded.isEmpty {
                                Menu {
                                    ForEach(hiddenGraded) { grade in
                                        Button("\(grade.groupLabel) — \(formatted(grade.grade))") {
                                            revealedGradedIds.insert(grade.id)
                                        }
                                    }
                                } label: {
                                    Label("Review a Graded Group", systemImage: "checklist")
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

    @ViewBuilder
    private func gradeRow(_ grade: ActivityGrade, isReviewing: Bool = false) -> some View {
        let draftBinding = Binding(
            get: { gradeDrafts[grade.id] ?? (grade.isGraded ? formatted(grade.grade) : "") },
            set: { gradeDrafts[grade.id] = $0 }
        )
        let trimmedDraft = draftBinding.wrappedValue.trimmingCharacters(in: .whitespaces)
        let parsedValue = trimmedDraft.isEmpty ? nil : Double(trimmedDraft)
        let validRange = GradeScaleSettings.validRange(max: gradeScaleMax)
        let isValid = parsedValue.map(validRange.contains) ?? false

        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(grade.groupLabel)
                    .foregroundStyle(AguaColor.textPrimary)
                if isReviewing {
                    Text("Already graded")
                        .font(.caption2)
                        .foregroundStyle(AguaColor.textMuted)
                }
            }
            Spacer()
            TextField(GradeScaleSettings.placeholderText(max: gradeScaleMax), text: draftBinding)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 70)
                .textFieldStyle(.roundedBorder)
            Button("Save") {
                guard let value = parsedValue, isValid else { return }
                if store.gradeGroup(groupNumber: grade.groupNumber, activityName: grade.activityName, grade: value) {
                    gradeDrafts[grade.id] = nil
                }
            }
            .buttonStyle(.bordered)
            .disabled(!isValid)

            if isReviewing {
                Button {
                    revealedGradedIds.remove(grade.id)
                    gradeDrafts[grade.id] = nil
                } label: {
                    Image(systemName: "chevron.up.circle")
                }
                .buttonStyle(.plain)
                .foregroundStyle(AguaColor.textMuted)
            }
        }
    }

    private func formatted(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
}
