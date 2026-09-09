//
//  RosterView.swift
//  RandyTheStudent
//
//  Add / edit / delete students. Replaces the "Edicion" control group
//  from the old Classes.swift.
//

import SwiftUI
import AguaDesign

struct RosterView: View {
    var store: ClassStore

    @State private var studentId = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var editingStudent: Student?
    @State private var studentPendingDeletion: Student?
    @FocusState private var focusedField: Field?

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
