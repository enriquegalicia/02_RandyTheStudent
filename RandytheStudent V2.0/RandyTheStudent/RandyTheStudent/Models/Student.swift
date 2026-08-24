//
//  Student.swift
//  RandyTheStudent
//

import Foundation

struct Student: Identifiable, Hashable {
    var id: Int
    var studentId: String
    var firstName: String
    var lastName: String
    var email: String
    var participations: Double

    var fullName: String { "\(firstName) \(lastName)" }
}
