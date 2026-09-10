//
//  GroupsView.swift
//  RandyTheStudent
//
//  Generate random, history-balanced groups and optionally save them as a
//  gradeable activity. Replaces the "Randy"/"Grupo" control groups from
//  the old Classes.swift, including its tap-a-row-then-Up/Down reordering
//  flow — modernized here as standard drag-to-reorder.
//

import SwiftUI
import AguaDesign

struct GroupsView: View {
    var store: ClassStore

    @State private var groupCount = 2
    @State private var activityName = ""
    @State private var showingSavedConfirmation = false
    @FocusState private var isActivityNameFocused: Bool

    private let groupCountRange = 2...6

    private struct DisplayedMember: Identifiable {
        var id: UUID { member.id }
        var groupNumber: Int
        var member: GroupMember
    }

    private var flattenedMembers: [DisplayedMember] {
        store.groups.sorted { $0.number < $1.number }.flatMap { group in
            group.members.map { DisplayedMember(groupNumber: group.number, member: $0) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: AguaSpacing.s) {
                    AguaGroupHeader(String(localized: "Number of Groups"))
                    Picker("Group count", selection: $groupCount) {
                        ForEach(groupCountRange, id: \.self) { count in
                            // A segmented Picker disables the individual segment
                            // whose label carries .disabled(), not just the whole
                            // control — so you can't select more groups than there
                            // are students to put in them.
                            Text("\(count)")
                                .tag(count)
                                .disabled(count > store.students.count)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: store.students.count) { _, newCount in
                        if groupCount > newCount {
                            groupCount = max(groupCountRange.lowerBound, newCount)
                        }
                    }

                    Button {
                        store.generateGroups(count: groupCount)
                    } label: {
                        Label("Generate Groups", systemImage: "shuffle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AguaColor.Accent.blue)
                    .disabled(store.students.isEmpty || groupCount > store.students.count)

                    if !store.groups.isEmpty {
                        HStack(spacing: AguaSpacing.s) {
                            TextField("Activity name", text: $activityName)
                                .textFieldStyle(.roundedBorder)
                                .focused($isActivityNameFocused)
                                .submitLabel(.done)
                                .onSubmit(saveActivity)
                            Button("Save", action: saveActivity)
                                .buttonStyle(.bordered)
                                .disabled(activityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
                .padding(AguaSpacing.m)

                if store.groups.isEmpty {
                    ContentUnavailableView(
                        "No Groups Yet",
                        systemImage: "person.2.badge.gearshape",
                        description: Text(store.students.isEmpty ? "Add students to the roster first." : "Tap Generate Groups to create balanced groups.")
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(flattenedMembers) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.member.studentName)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(AguaColor.textPrimary)
                                    // A ternary nested inside this string's own interpolation would
                                    // force its branches to plain String (not LocalizedStringKey),
                                    // silently skipping table lookup — resolve it via String(localized:)
                                    // first instead, so both branches get a translated key.
                                    Text("\(ClassStore.displayRole(entry.member.role)) · \(Self.previouslyHeldText(entry.member.priorRoleCount))")
                                        .font(.caption)
                                        .foregroundStyle(AguaColor.textMuted)
                                }
                                Spacer()
                                Text("Group \(entry.groupNumber)")
                                    .font(.caption.bold())
                                    .foregroundStyle(AguaColor.Accent.blue)
                            }
                            .accessibilityElement(children: .combine)
                            .listRowBackground(AguaColor.bgCard)
                        }
                        .onMove { source, destination in
                            store.moveMember(from: source, to: destination)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .toolbar { EditButton() }
                }
            }
            .aguaBackground()
        }
        .alert("Activity Saved", isPresented: $showingSavedConfirmation) {
            Button("OK") {}
        } message: {
            Text("Open the Activities tab to grade each group.")
        }
    }

    private func saveActivity() {
        guard store.saveCurrentAssignment(asActivity: activityName) else { return }
        activityName = ""
        isActivityNameFocused = false
        showingSavedConfirmation = true
    }

    private static func previouslyHeldText(_ count: Int) -> String {
        count == 1
            ? String(localized: "previously held 1 time")
            : String(localized: "previously held \(count) times")
    }
}
