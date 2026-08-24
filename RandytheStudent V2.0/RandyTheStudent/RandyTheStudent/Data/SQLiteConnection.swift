//
//  SQLiteConnection.swift
//  RandyTheStudent
//
//  Thin, parameterized wrapper around the raw sqlite3 C API. Replaces the
//  old DataBase.swift, which built every query by string interpolation —
//  harmless-looking until a student's name or email contained a `"`, which
//  silently broke that save. Opens/closes a fresh connection per call, same
//  as before; fine for this app's small, local, single-user data.
//

import Foundation
import SQLite3

enum SQLiteValue {
    case text(String)
    case double(Double)
}

struct SQLiteError: Error {
    let message: String
}

final class SQLiteConnection {
    private let path: String

    init(fileName: String) {
        let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        self.path = (docsDir as NSString).appendingPathComponent(fileName)
    }

    /// Creates the table if the database file doesn't exist yet. `columns` are
    /// appended after an auto-incrementing `ID INTEGER PRIMARY KEY` column.
    func createTableIfNeeded(table: String, columns: [(name: String, type: String)]) throws {
        guard !FileManager.default.fileExists(atPath: path) else { return }
        try withConnection { db in
            var sql = "CREATE TABLE IF NOT EXISTS \(table) (ID INTEGER PRIMARY KEY AUTOINCREMENT"
            for column in columns {
                sql += ", \(column.name) \(column.type)"
            }
            sql += ")"
            try exec(db, sql)
        }
    }

    @discardableResult
    func run(_ sql: String, params: [SQLiteValue] = []) throws -> Int {
        try withConnection { db in
            let statement = try prepare(db, sql, params: params)
            defer { sqlite3_finalize(statement) }
            let step = sqlite3_step(statement)
            guard step == SQLITE_DONE || step == SQLITE_ROW else {
                throw SQLiteError(message: String(cString: sqlite3_errmsg(db)))
            }
            return Int(sqlite3_last_insert_rowid(db))
        }
    }

    /// Returns every row as an array of column values, each stringified the
    /// way the original app treated them (NULL becomes "").
    func query(_ sql: String, params: [SQLiteValue] = [], columnCount: Int) throws -> [[String]] {
        try withConnection { db in
            let statement = try prepare(db, sql, params: params)
            defer { sqlite3_finalize(statement) }
            var rows: [[String]] = []
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String] = []
                for column in 0..<columnCount {
                    if let text = sqlite3_column_text(statement, Int32(column)) {
                        row.append(String(cString: text))
                    } else {
                        row.append("")
                    }
                }
                rows.append(row)
            }
            return rows
        }
    }

    /// Convenience for a single scalar column value from the first row, or
    /// "" if there were no matching rows.
    func queryScalar(_ sql: String, params: [SQLiteValue] = []) throws -> String {
        try query(sql, params: params, columnCount: 1).first?.first ?? ""
    }

    // MARK: - internals

    private func withConnection<T>(_ body: (OpaquePointer?) throws -> T) throws -> T {
        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            throw SQLiteError(message: "Couldn't open database")
        }
        defer { sqlite3_close(db) }
        return try body(db)
    }

    private func exec(_ db: OpaquePointer?, _ sql: String) throws {
        guard sqlite3_exec(db, sql, nil, nil, nil) == SQLITE_OK else {
            throw SQLiteError(message: String(cString: sqlite3_errmsg(db)))
        }
    }

    private func prepare(_ db: OpaquePointer?, _ sql: String, params: [SQLiteValue]) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            let message = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw SQLiteError(message: message)
        }
        for (index, value) in params.enumerated() {
            let position = Int32(index + 1)
            switch value {
            case .text(let text):
                sqlite3_bind_text(statement, position, text, -1, SQLITE_TRANSIENT)
            case .double(let number):
                sqlite3_bind_double(statement, position, number)
            }
        }
        return statement
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
