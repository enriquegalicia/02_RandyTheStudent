//
//  ParticipationPickerView.swift
//  RandyTheStudent
//
//  Picks a random student, weighted toward whoever has participated the
//  least, and lets the teacher log that they answered. Replaces the
//  "select to participate" flow from the old Classes.swift.
//

import SwiftUI
import AguaDesign

struct ParticipationPickerView: View {
    var store: ClassStore

    var body: some View {
        NavigationStack {
            VStack(spacing: AguaSpacing.xl) {
                Spacer()

                if let participant = store.selectedParticipant {
                    VStack(spacing: AguaSpacing.s) {
                        Text(participant.fullName)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(AguaColor.textPrimary)
                        Text(Int(participant.participations) == 1 ? "1 participation so far" : "\(Int(participant.participations)) participations so far")
                            .font(.subheadline)
                            .foregroundStyle(AguaColor.textMuted)
                    }
                    .padding(AguaSpacing.l)
                    .frame(maxWidth: .infinity)
                    .aguaElevated()
                    .accessibilityElement(children: .combine)
                } else {
                    ContentUnavailableView(
                        "Ready When You Are",
                        systemImage: "shuffle",
                        description: Text(store.students.isEmpty ? "Add students to the roster first." : "Tap Pick a Student to choose someone at random.")
                    )
                }

                Spacer()

                Button {
                    store.pickParticipant()
                } label: {
                    Label("Pick a Student", systemImage: "shuffle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AguaColor.Accent.blue)
                .controlSize(.large)
                .disabled(store.students.isEmpty)

                Button {
                    store.recordParticipationForSelectedParticipant()
                } label: {
                    Label("Mark as Participated", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(store.selectedParticipant == nil)
            }
            .padding(AguaSpacing.l)
            .aguaBackground()
        }
    }
}
