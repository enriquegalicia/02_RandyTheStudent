//
//  RosterView.swift
//  RandyTheStudent
//
//  Add / edit / delete students. Replaces the "Edicion" control group
//  from the old Classes.swift.
//
//  Also handles roster CSV import/export — so a roster can be bulk-added
//  from a spreadsheet, shared with another professor, or edited outside
//  the app and brought back in — plus a downloadable template so it's
//  obvious what columns are expected.
//

import SwiftUI
import AguaDesign
import UniformTypeIdentifiers

struct RosterView: View {
    var store: ClassStore
    var className: String

    @State private var studentId = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var editingStudent: Student?
    @State private var studentPendingDeletion: Student?
    @FocusState private var focusedField: Field?

    @State private var isShowingFileImporter = false
    @State private var isShowingShareSheet = false
    @State private var shareURL: URL?
    @State private var importResultMessage: String?

    private enum Field {
        case studentId, firstName, lastName, email
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: AguaSpacing.s) {
                        TextField("Student ID", text: $studentId)
                            .disabled(editingStudent != nil)
                            .focused($focusedField, equals: .studentId)
                        TextField("First Name", text: $firstName)
                            .focused($focusedField, equals: .firstName)
                        TextField("Last Name", text: $lastName)
                            .focused($focusedField, equals: .lastName)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .focused($focusedField, equals: .email)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, AguaSpacing.xs)

                    HStack(spacing: AguaSpacing.s) {
                        if let editingStudent {
                            Button("Update") {
                                if store.updateStudent(studentId: editingStudent.studentId, firstName: firstName, lastName: lastName, email: email) {
                                    focusedField = nil
                                    clearForm()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AguaColor.Accent.blue)

                            Button("Cancel", role: .cancel) {
                                focusedField = nil
                                clearForm()
                            }
                        } else {
                            Button("Add Student") {
                                if store.addStudent(studentId: studentId, firstName: firstName, lastName: lastName, email: email) {
                                    focusedField = nil
                                    clearForm()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AguaColor.Accent.blue)
                        }
                    }
                } header: {
                    AguaGroupHeader(editingStudent == nil ? String(localized: "Add a Student") : String(localized: "Edit Student"))
                }
                .listRowBackground(AguaColor.bgCard)

                Section {
                    if store.students.isEmpty {
                        ContentUnavailableView("No Students Yet", systemImage: "person.crop.circle.badge.plus", description: Text("Add your first student above."))
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(store.students.sorted(by: { $0.lastName < $1.lastName })) { student in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.fullName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(AguaColor.textPrimary)
                                Text("\(student.studentId) · \(student.email)")
                                    .font(.caption)
                                    .foregroundStyle(AguaColor.textMuted)
                                Text(Int(student.participations) == 1 ? "1 participation" : "\(Int(student.participations)) participations")
                                    .font(.caption)
                                    .foregroundStyle(AguaColor.textSecondary)
                            }
                            .accessibilityElement(children: .combine)
                            .contentShape(Rectangle())
                            .onTapGesture { beginEditing(student) }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    studentPendingDeletion = student
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    beginEditing(student)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(AguaColor.Accent.blue)
                            }
                        }
                    }
                } header: {
                    AguaGroupHeader(String(localized: "Roster (\(store.students.count))"))
                }
                .listRowBackground(AguaColor.bgCard)
            }
            .scrollContentBackground(.hidden)
            .aguaBackground()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            isShowingFileImporter = true
                        } label: {
                            Label("Import CSV", systemImage: "square.and.arrow.down")
                        }
                        Button {
                            shareCSV(store.exportRosterCSVText(), named: "\(className)-Roster.csv")
                        } label: {
                            Label("Export Roster (CSV)", systemImage: "square.and.arrow.up")
                        }
                        .disabled(store.students.isEmpty)
                        Button {
                            shareCSV(RosterCSV.templateText, named: "RandoSquad-Roster-Template.csv")
                        } label: {
                            Label("Get CSV Template", systemImage: "doc.text")
                        }
                    } label: {
                        Label("Roster File", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .confirmationDialog(
            "Delete this student?",
            isPresented: Binding(
                get: { studentPendingDeletion != nil },
                set: { isPresented in if !isPresented { studentPendingDeletion = nil } }
            ),
            titleVisibility: .visible,
            presenting: studentPendingDeletion
        ) { student in
            Button("Delete \(student.fullName)", role: .destructive) {
                store.deleteStudent(studentId: student.studentId)
                if editingStudent?.id == student.id { clearForm() }
                studentPendingDeletion = nil
            }
            Button("Cancel", role: .cancel) { studentPendingDeletion = nil }
        }
        .fileImporter(isPresented: $isShowingFileImporter, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
            handleImport(result)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let shareURL {
                ActivityView(activityItems: [shareURL])
            }
        }
        .alert(
            "Import Complete",
            isPresented: Binding(
                get: { importResultMessage != nil },
                set: { isPresented in if !isPresented { importResultMessage = nil } }
            )
        ) {
            Button("OK") { importResultMessage = nil }
        } message: {
            Text(importResultMessage ?? "")
        }
    }

    private func shareCSV(_ text: String, named filename: String) {
        guard let url = CSV.writeTempFile(text, named: filename) else { return }
        shareURL = url
        isShowingShareSheet = true
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure:
            importResultMessage = String(localized: "Couldn't read that file. Make sure it's a CSV or plain text file.")
        case .success(let url):
            let didAccess = url.startAccessingSecurityScopedResource()
            defer { if didAccess { url.stopAccessingSecurityScopedResource() } }
            guard let text = CSV.readText(at: url) else {
                importResultMessage = String(localized: "Couldn't read that file. Make sure it's a CSV or plain text file.")
                return
            }
            let summary = store.importStudentsCSV(text)
            if summary.imported == 0, summary.duplicates == 0, summary.invalid == 0 {
                importResultMessage = String(localized: "No importable rows were found in that file.")
            } else {
                importResultMessage = String(localized: "Added \(summary.imported) · Skipped \(summary.duplicates) already in the roster · Skipped \(summary.invalid) with missing or invalid data.")
            }
        }
    }

    private func beginEditing(_ student: Student) {
        editingStudent = student
        studentId = student.studentId
        firstName = student.firstName
        lastName = student.lastName
        email = student.email
    }

    private func clearForm() {
        editingStudent = nil
        studentId = ""
        firstName = ""
        lastName = ""
        email = ""
    }
}
