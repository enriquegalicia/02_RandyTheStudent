//
//  Subtitulados.swift
//  RandyTheStudent
//
//  Swift port of the original Subtitulados.m (Objective-C).
//  Builds "Title"/"Subtitle" string arrays (and a couple of other simple
//  shapes) out of columnar NSDictionary data — e.g. dic["Nombre"] is an
//  NSArray of one name per row. Kept `@objc` with the original selector
//  names so not-yet-converted Objective-C callers (RandyMenu.m, Classes.m)
//  keep compiling unchanged during the migration.
//

import Foundation

@objc(Subtitulados)
class Subtitulados: NSObject {

    // MARK: - helpers

    private func col(_ dic: NSDictionary, _ key: String) -> [Any] {
        (dic[key] as? [Any]) ?? []
    }

    private func str(_ arr: [Any], _ i: Int) -> String {
        "\(arr[i])"
    }

    // MARK: - Subtitulado para Tablas

    @objc(titidc1subc2c3:c1:c2:c3:)
    func titidc1subc2c3(_ dic: NSDictionary, c1: String, c2: String, c3: String) -> NSDictionary {
        let id = col(dic, "Id"), C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3)
        var titulos: [String] = []
        var subtitulos: [String] = []
        if id.count >= 1 {
            for a in 0..<id.count {
                titulos.append("\(str(id, a))_\(str(C1, a))")
                subtitulos.append("\(str(C2, a))_\(str(C3, a))")
            }
        } else {
            titulos = ["Sin Registros"]
            subtitulos = ["Nos Falta Seleccion e Informacion"]
        }
        return ["Titulo": titulos, "Subtitulo": subtitulos]
    }

    @objc(titc1subc2c3:c1:c2:c3:)
    func titc1subc2c3(_ dic: NSDictionary, c1: String, c2: String, c3: String) -> NSDictionary {
        let C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3)
        var titulos: [String] = []
        var subtitulos: [String] = []
        if C1.count >= 1 {
            for a in 0..<C1.count {
                titulos.append("\(a + 1)_\(str(C1, a))")
                subtitulos.append("\(str(C2, a))_\(str(C3, a))")
            }
        } else {
            titulos = ["Sin Registros"]
            subtitulos = ["Nos Falta Seleccion e Informacion"]
        }
        return ["Titulo": titulos, "Subtitulo": subtitulos]
    }

    @objc(titidc1c2subc3c4:c1:c2:c3:c4:)
    func titidc1c2subc3c4(_ dic: NSDictionary, c1: String, c2: String, c3: String, c4: String) -> NSDictionary {
        let id = col(dic, "Id"), C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3), C4 = col(dic, c4)
        var titulos: [String] = []
        var subtitulos: [String] = []
        if id.count >= 1 {
            for a in 0..<id.count {
                titulos.append("\(str(id, a))_\(str(C1, a)) \(str(C2, a))")
                subtitulos.append("\(str(C3, a))_\(str(C4, a))")
            }
        } else {
            titulos = ["Sin Registros"]
            subtitulos = ["Nos Falta Seleccion e Informacion"]
        }
        return ["Titulo": titulos, "Subtitulo": subtitulos]
    }

    @objc(titidc1c2subc3c4c5:c1:c2:c3:c4:c5:)
    func titidc1c2subc3c4c5(_ dic: NSDictionary, c1: String, c2: String, c3: String, c4: String, c5: String) -> NSDictionary {
        let id = col(dic, "Id"), C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3), C4 = col(dic, c4), C5 = col(dic, c5)
        var titulos: [String] = []
        var subtitulos: [String] = []
        if id.count >= 1 {
            for a in 0..<id.count {
                titulos.append("\(str(id, a))_\(str(C1, a)) \(str(C2, a))")
                subtitulos.append("\(str(C3, a))_\(str(C4, a))_\(str(C5, a))")
            }
        } else {
            titulos = ["Sin Registros"]
            subtitulos = ["Nos Falta Seleccion e Informacion"]
        }
        return ["Titulo": titulos, "Subtitulo": subtitulos]
    }

    @objc(titc1c2subc3c4:c1:c2:c3:c4:)
    func titc1c2subc3c4(_ dic: NSDictionary, c1: String, c2: String, c3: String, c4: String) -> NSDictionary {
        let C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3), C4 = col(dic, c4)
        var titulos: [String] = []
        var subtitulos: [String] = []
        if C1.count >= 1 {
            for a in 0..<C1.count {
                titulos.append("\(str(C1, a))_\(str(C2, a))")
                subtitulos.append("\(str(C3, a))_\(str(C4, a))")
            }
        } else {
            titulos = ["Sin Registros"]
            subtitulos = ["Nos Falta Seleccion e Informacion"]
        }
        return ["Titulo": titulos, "Subtitulo": subtitulos]
    }

    // MARK: - Subtitulado para ComboBox

    @objc(titidc1:c1:)
    func titidc1(_ titsub: NSDictionary, c1: String) -> NSMutableArray {
        let id = col(titsub, "Id"), nombre = col(titsub, c1)
        let titulos = NSMutableArray()
        if nombre.count >= 1 {
            for a in 0..<nombre.count {
                titulos.add("\(str(id, a))_\(str(nombre, a))")
            }
        } else {
            titulos.add("Sin Archivos")
        }
        return titulos
    }

    @objc(MAtitc1:c1:)
    func MAtitc1(_ titsub: NSDictionary, c1: String) -> NSMutableArray {
        let nombre = col(titsub, c1)
        let titulos = NSMutableArray()
        if nombre.count >= 1 {
            for a in 0..<nombre.count {
                titulos.add(str(nombre, a))
            }
        } else {
            titulos.add("Sin Archivos")
        }
        return titulos
    }

    @objc(tit1idc1:c1:)
    func tit1idc1(_ titsub: NSDictionary, c1: String) -> String {
        let id = col(titsub, "Id"), nombre = col(titsub, c1)
        guard nombre.count >= 1 else { return "Sin Archivos" }
        // matches the original: loops through all rows, keeps only the last one
        var titulo = ""
        for a in 0..<nombre.count {
            titulo = "\(str(id, a))_\(str(nombre, a))"
        }
        return titulo
    }

    @objc(titc1:c1:)
    func titc1(_ titsub: NSDictionary, c1: String) -> String {
        let nombre = col(titsub, c1)
        guard nombre.count >= 1 else { return "Sin Archivos" }
        var titulo = ""
        for a in 0..<nombre.count {
            titulo = str(nombre, a)
        }
        return titulo
    }

    // MARK: - NSDictionary to Array

    @objc(DictoArrayc1c2c3:c1:c2:c3:)
    func DictoArrayc1c2c3(_ dic: NSDictionary, c1: String, c2: String, c3: String) -> NSArray {
        let C1 = col(dic, c1), C2 = col(dic, c2), C3 = col(dic, c3)
        let informacion = NSMutableArray()
        if C1.count >= 1 {
            for a in 0..<C1.count {
                informacion.add([str(C1, a), str(C2, a), str(C3, a)])
            }
        } else {
            informacion.add(["Sin Nombre", "Sin Apellido", "Sin Matricula"])
        }
        return informacion
    }

    // MARK: - Graph data prep

    @objc(subgraf:acumulados:campos:info:info2:info3:info4:)
    func subgraf(_ roles: NSDictionary, acumulados acum: NSDictionary, campos camp: NSDictionary,
                 info: NSArray, info2: NSArray, info3: NSArray, info4: NSArray) -> NSDictionary {
        // Roles
        let campos = (roles[info[0] as! String] as? [Any]) ?? []

        // Acumulados
        let posicion = col(acum, info2[0] as! String)
        let ccalif = col(acum, info2[1] as! String)
        let scalif = col(acum, info2[2] as! String)
        let cPosicion = col(camp, info3[1] as! String)
        let cCalif = col(camp, info3[2] as! String)

        var acumulacion: [String] = []
        if posicion.count > 0 {
            for a in 0..<posicion.count {
                let cVal = (ccalif[a] as? NSNumber)?.doubleValue ?? Double("\(ccalif[a])") ?? 0
                let sVal = (scalif[a] as? NSNumber)?.doubleValue ?? Double("\(scalif[a])") ?? 0
                if cVal * 100 > sVal {
                    acumulacion.append(String(format: "%f", cVal * 100))
                } else {
                    acumulacion.append(str(scalif, a))
                }
            }
        }

        var ccampos: [[String]] = []
        var cvalor: [[Any]] = []
        if posicion.count > 0 {
            for b in 0..<posicion.count {
                var campos2: [String] = []
                var valor: [Any] = []
                var d = 1
                if cPosicion.count > 0 {
                    for c in 0..<cPosicion.count {
                        if str(posicion, b) == str(cPosicion, c) {
                            campos2.append("\(d)")
                            valor.append(cCalif[c])
                            d += 1
                        }
                    }
                }
                ccampos.append(campos2)
                cvalor.append(valor)
            }
        }

        return [
            (info4[0] as! String): campos,
            (info4[1] as! String): acumulacion,
            (info4[2] as! String): ccampos,
            (info4[3] as! String): cvalor,
        ]
    }
}
