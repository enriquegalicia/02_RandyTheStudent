//
//  SettingsView.swift
//  RandyTheStudent
//
//  App-wide preferences. Currently just the grading scale — what "full
//  marks" means (0–10, 0–100, or anything else) — since that's a personal
//  grading-style choice, not something tied to any one class.
//

import SwiftUI
import AguaDesign

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(GradeScaleSettings.userDefaultsKey) private var gradeScaleMax: Double = GradeScaleSettings.defaultMax

    /// A separate typing draft, committed on submit — same reasoning as the
    /// grade drafts in ActivitiesView: reformatting the field to match a
    /// parsed Double on every keystroke fights the user's cursor.
    @State private var customText: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: AguaSpacing.s) {
                        ForEach(GradeScaleSettings.presets, id: \.self) { preset in
                            Button(presetLabel(preset)) {
                                gradeScaleMax = preset
                            }
                            .buttonStyle(.bordered)
                            .tint(gradeScaleMax == preset ? AguaColor.Accent.blue : AguaColor.textMuted)
                        }
                    }

                    HStack {
                        Text("Custom Maximum")
                            .foregroundStyle(AguaColor.textPrimary)
                        Spacer()
                        TextField("Max", text: $customText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.done)
                            .onSubmit(commitCustomText)
                    }
                } header: {
                    AguaGroupHeader(String(localized: "Grading Scale"))
                } footer: {
                    Text("Grades are entered out of \(Int(gradeScaleMax)). You can still enter more than that for bonus points — up to \(Int(GradeScaleSettings.validRange(max: gradeScaleMax).upperBound)).")
                }
                .listRowBackground(AguaColor.bgCard)
            }
            .scrollContentBackground(.hidden)
            .aguaBackground()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        commitCustomText()
                        dismiss()
                    }
                }
            }
            .onAppear { customText = presetLabel(gradeScaleMax) }
            .onChange(of: gradeScaleMax) { _, newValue in customText = presetLabel(newValue) }
        }
    }

    private func commitCustomText() {
        guard let value = Double(customText.trimmingCharacters(in: .whitespaces)), value > 0 else {
            customText = presetLabel(gradeScaleMax)
            return
        }
        gradeScaleMax = value
    }

    private func presetLabel(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
}

#Preview {
    SettingsView()
}
