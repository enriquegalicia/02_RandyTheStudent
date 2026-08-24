//
//  ClassFile.swift
//  RandyTheStudent
//

import Foundation

/// One entry in the class library — a display name mapped to the on-disk
/// SQLite file that holds that class's roster/groups/activities.
struct ClassFile: Identifiable, Hashable {
    var id: Int
    var name: String
    var databaseFileName: String
}
