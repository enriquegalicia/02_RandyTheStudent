//
//  CreditsView.swift
//  RandyTheStudent
//
//  About / credits screen. Replaces Credits.swift + Credits.xib, presented
//  with AguaDesign instead of the old chalkboard illustration and a
//  tap-anywhere-on-the-word-"Back" gesture. RandoSquad is solely developed
//  by Enrique Galicia — the original 2014 team credits were dropped.
//

import SwiftUI
import AguaDesign

private struct Credit: Identifiable {
    let id = UUID()
    let role: String
    let names: String
}

private let currentCredits: [Credit] = [
    Credit(role: "Developer", names: "Enrique Galicia"),
]

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: AguaSpacing.xs) {
                        Text("RandoSquad")
                            .font(.title2.bold())
                            .foregroundStyle(AguaColor.textPrimary)
                        Text("Version \(appVersion)")
                            .font(.subheadline)
                            .foregroundStyle(AguaColor.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AguaSpacing.m)
                    .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(currentCredits) { credit in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(credit.role)
                                .font(.caption)
                                .foregroundStyle(AguaColor.textMuted)
                            Text(credit.names)
                                .foregroundStyle(AguaColor.textPrimary)
                        }
                    }
                } header: {
                    AguaGroupHeader(String(localized: "Credits"))
                }
                .listRowBackground(AguaColor.bgCard)

                Section {
                    Text("Powered by Magnificent")
                        .font(.footnote)
                        .foregroundStyle(AguaColor.textMuted)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .aguaBackground()
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CreditsView()
}
