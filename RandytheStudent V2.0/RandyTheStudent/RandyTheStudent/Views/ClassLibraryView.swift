//
//  ClassLibraryView.swift
//  RandyTheStudent
//
//  Pick / create / rename a class — replaces RandyMenu.
//

import SwiftUI
import AguaDesign

struct ClassLibraryView: View {
    var library: ClassLibraryStore
    @Binding var selectedClass: ClassFile?
    @Binding var showingCredits: Bool

    @State private var newClassName = ""
    @State private var renamingClass: ClassFile?
    @State private var renameText = ""
    @State private var classPendingDeletion: ClassFile?

    var body: some View {
        List(selection: $selectedClass) {
            Section {
                if library.classes.isEmpty {
                    ContentUnavailableView("No Classes Yet", systemImage: "person.3", description: Text("Create your first class below."))
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(library.classes) { classFile in
                        NavigationLink(value: classFile) {
                            Label(classFile.name, systemImage: "person.3.fill")
                        }
                        .foregroundStyle(AguaColor.textPrimary)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                classPendingDeletion = classFile
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                renamingClass = classFile
                                renameText = classFile.name
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(AguaColor.Accent.blue)
                        }
                    }
                }
            } header: {
                AguaGroupHeader(String(localized: "Classes"))
            }

            Section {
                HStack(spacing: AguaSpacing.s) {
                    TextField("New class name", text: $newClassName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(createClass)
                    Button("Add", action: createClass)
                        .buttonStyle(.borderedProminent)
                        .tint(AguaColor.Accent.blue)
                        .disabled(newClassName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .aguaBackground()
        .navigationTitle("RandoSquad")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingCredits = true
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }
        }
        .alert("Rename Class", isPresented: .constant(renamingClass != nil), presenting: renamingClass) { classFile in
            TextField("Class name", text: $renameText)
            Button("Cancel", role: .cancel) { renamingClass = nil }
            Button("Rename") {
                library.rename(classFile, to: renameText)
                renamingClass = nil
            }
        }
        .confirmationDialog(
            "Delete this class and everything in it?",
            isPresented: Binding(
                get: { classPendingDeletion != nil },
                set: { isPresented in if !isPresented { classPendingDeletion = nil } }
            ),
            titleVisibility: .visible,
            presenting: classPendingDeletion
        ) { classFile in
            Button("Delete \"\(classFile.name)\"", role: .destructive) {
                if selectedClass?.id == classFile.id { selectedClass = nil }
                library.delete(classFile)
                classPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) { classPendingDeletion = nil }
        }
        .alert("Something Went Wrong", isPresented: .constant(library.errorMessage != nil), actions: {
            Button("OK") { library.clearError() }
        }, message: {
            Text(library.errorMessage ?? "")
        })
    }

    private func createClass() {
        let trimmed = newClassName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if library.createClass(named: trimmed) {
            newClassName = ""
            selectedClass = library.classes.first { $0.name == trimmed }
        }
    }
}
