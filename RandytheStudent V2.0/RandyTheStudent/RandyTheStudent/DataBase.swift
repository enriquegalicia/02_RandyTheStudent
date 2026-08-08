//
//  DataBase.swift
//  RandyTheStudent
//
//  Swift port of the original DataBase.m (Objective-C) — a thin wrapper
//  around the raw sqlite3 C API. Kept `@objc` with the original selector
//  names so not-yet-converted Objective-C callers (RandyMenu.m, Classes.m)
//  keep compiling unchanged during the migration.
//
//  Preserves the original's behavior faithfully, including opening/closing
//  a fresh sqlite3 connection on nearly every call (inefficient, but that's
//  how the original worked, and this is a small single-user local database)
//  and building SQL by direct string interpolation (no bound parameters —
//  same as the original; fine for this app's offline, non-networked,
//  single-user data, but not a pattern to copy into anything reachable by
//  untrusted input).
//
//  One deliberate behavior change: the original inserted whatever
//  `sqlite3_column_text` returned — including NULL for a NULL column —
//  straight into an NSMutableArray, which throws in Objective-C ("attempt
//  to insert nil object"). Swift's typed arrays can't hold nil here at all,
//  so a NULL column now becomes "" instead of crashing.
//

import Foundation
import SQLite3

@objc(DataBase)
class DataBase: NSObject {

    private var mainDB: OpaquePointer?
    private var mainDBPath: String = ""

    @objc(initDB:Tablas:)
    init(file: String, tablas: NSArray) {
        super.init()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        mainDBPath = (docsDir as NSString).appendingPathComponent(file)
        iniciarDB(tablas)
    }

    private func iniciarDB(_ tablas: NSArray) {
        guard !FileManager.default.fileExists(atPath: mainDBPath) else { return }
        guard sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK else { return }
        defer { sqlite3_close(mainDB) }

        for case let tabla as NSArray in tablas {
            guard tabla.count > 0 else { continue }
            var oracion = "CREATE TABLE IF NOT EXISTS"
            for b in 0..<tabla.count {
                let campo = "\(tabla[b])"
                if b == 0 {
                    oracion += " \(campo) (ID INTEGER PRIMARY KEY AUTOINCREMENT,"
                } else if b < tabla.count - 1 {
                    oracion += " \(campo),"
                } else {
                    oracion += " \(campo))"
                }
            }
            sqlite3_exec(mainDB, oracion, nil, nil, nil)
        }
    }

    @objc(revisarBD:Valores:Testigo:Tabla:Campo:Nombre:)
    func revisarBD(_ campos: NSArray, valores: NSArray, testigo: String, tabla: String, campo: String, nombre: String) {
        var agrabar = false
        if sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK {
            let querySQL = "SELECT \(testigo) FROM \(tabla) WHERE \(campo)=\"\(nombre)\""
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(mainDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_ROW {
                    // already exists
                } else {
                    agrabar = true
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(mainDB)
        }
        if agrabar {
            guardarBD(campos, valores: valores, tabla: tabla)
        }
    }

    @objc(revisarBD2T:Valores:Testigo:Tabla:Campo:Nombre:Campo2:Nombre2:)
    func revisarBD2T(_ campos: NSArray, valores: NSArray, testigo: String, tabla: String, campo: String, nombre: String, campo2: String, nombre2: String) {
        var agrabar = false
        if sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK {
            let querySQL = "SELECT \(testigo) FROM \(tabla) WHERE \(campo)=\"\(nombre)\" AND \(campo2)=\"\(nombre2)\""
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(mainDB, querySQL, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_ROW {
                    // already exists
                } else {
                    agrabar = true
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(mainDB)
        }
        if agrabar {
            guardarBD(campos, valores: valores, tabla: tabla)
        }
    }

    @objc(guardarBD:Valores:Tabla:)
    func guardarBD(_ campos: NSArray, valores: NSArray, tabla: String) {
        guard sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK else { return }
        defer { sqlite3_close(mainDB) }

        guard campos.count > 0 else { return }
        var oracion = "INSERT INTO \(tabla)("
        for a in 0..<campos.count {
            if a < campos.count - 1 {
                oracion += "\(campos[a]),"
            } else {
                oracion += "\(campos[a])) VALUES "
            }
        }
        for a in 0..<valores.count {
            if a == 0 {
                oracion += "(\"\(valores[a])\","
            } else if a < valores.count - 1 {
                oracion += "\"\(valores[a])\","
            } else {
                oracion += "\"\(valores[a])\")"
            }
        }

        var statement: OpaquePointer?
        sqlite3_prepare_v2(mainDB, oracion, -1, &statement, nil)
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }

    @objc(update:)
    func update(_ nombre: String) {
        guard sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK else { return }
        defer { sqlite3_close(mainDB) }
        var statement: OpaquePointer?
        sqlite3_prepare_v2(mainDB, nombre, -1, &statement, nil)
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }

    @objc(getalltablesfromDB:campos:)
    func getalltablesfromDB(_ tabla: String, campos: NSArray) -> NSDictionary {
        getdatos(query: "SELECT * FROM \(tabla)", campos: campos)
    }

    @objc(getalldatafromstatement:campos:)
    func getalldatafromstatement(_ oracion: String, campos: NSArray) -> NSDictionary {
        getdatos(query: oracion, campos: campos)
    }

    private func getdatos(query: String, campos: NSArray) -> NSDictionary {
        var titcampos = [[String]](repeating: [], count: campos.count)

        if sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(mainDB, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    for b in 0..<campos.count {
                        let ninfo: String
                        if let text = sqlite3_column_text(statement, Int32(b)) {
                            ninfo = String(cString: text)
                        } else {
                            ninfo = ""
                        }
                        titcampos[b].append(ninfo)
                    }
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(mainDB)
        }

        let tlu = NSMutableDictionary()
        for a in 0..<campos.count {
            tlu[campos[a]] = titcampos[a]
        }
        return tlu
    }

    @objc(getselecteddatafromstatement:)
    func getselecteddatafromstatement(_ oracion: String) -> String {
        var selected = ""
        if sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK {
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(mainDB, oracion, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    if let text = sqlite3_column_text(statement, 0) {
                        selected = String(cString: text)
                    }
                }
                sqlite3_finalize(statement)
            }
            sqlite3_close(mainDB)
        }
        return selected
    }

    @objc(deletetable:Tablas:)
    func deletetable(_ table: String, tablas: NSArray) {
        guard sqlite3_open(mainDBPath, &mainDB) == SQLITE_OK else { return }
        defer { sqlite3_close(mainDB) }

        var statement: OpaquePointer?
        sqlite3_prepare_v2(mainDB, "DROP TABLE \(table)", -1, &statement, nil)
        sqlite3_step(statement)
        sqlite3_finalize(statement)

        var createSQL = ""
        for case let tabla as NSArray in tablas {
            guard tabla.count > 0 else { continue }
            var oracion = "CREATE TABLE IF NOT EXISTS"
            for b in 0..<tabla.count {
                let campo = "\(tabla[b])"
                if b == 0 {
                    oracion += " \(campo) (ID INTEGER PRIMARY KEY AUTOINCREMENT,"
                } else if b < tabla.count - 1 {
                    oracion += " \(campo),"
                } else {
                    oracion += " \(campo))"
                }
            }
            createSQL = oracion
        }

        var statement2: OpaquePointer?
        sqlite3_prepare_v2(mainDB, createSQL, -1, &statement2, nil)
        sqlite3_step(statement2)
        sqlite3_finalize(statement2)
    }
}
