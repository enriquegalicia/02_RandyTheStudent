//
//  Classes.swift
//  RandyTheStudent
//
//  Swift port of the original Classes.m (Objective-C) — the main
//  gradebook screen: student roster, random group assignment, activity
//  grading, and the two bar-chart summaries.
//
//  `@objc(Classes)` is required: both MainViewController_iPhone.xib and
//  MainViewController_iPad.xib load via the "nib name matches class
//  name" convention, and RandyMenu.swift instantiates this class
//  directly by name.
//
//  This is a faithful, line-for-line port. The random-group-assignment
//  algorithm (Randear/goup/godown) in particular is intricate index
//  arithmetic ported as literally as possible from the original — it is
//  the highest-risk part of this whole migration to get subtly wrong,
//  since a bug here silently produces incorrect group assignments rather
//  than a crash. Test it thoroughly against the pre-migration app's
//  behavior before relying on it.
//
//  One deliberate change: `delegatem` was `assign` (unsafe unretained)
//  in the original. Made it `weak`, standard delegate practice.
//

import UIKit

@objc(ClassesDelegate)
protocol ClassesDelegate: NSObjectProtocol {
    @objc(ClassesDidFinish:)
    func classesDidFinish(_ controller: Classes!)
}

@objc(Classes)
class Classes: UIViewController, BasicTableDelegate, ComboDelegate, UITextFieldDelegate {

    @objc weak var delegatem: ClassesDelegate?
    @objc var archivo1: String?

    @IBOutlet private weak var buNewClass: UIButton!
    @IBOutlet private weak var buG2: UIButton!
    @IBOutlet private weak var buG3: UIButton!
    @IBOutlet private weak var buG4: UIButton!
    @IBOutlet private weak var buG5: UIButton!
    @IBOutlet private weak var buG6: UIButton!
    @IBOutlet private weak var buSel: UIButton!
    @IBOutlet private weak var buPart: UIButton!
    @IBOutlet private weak var buEdit: UIButton!
    @IBOutlet private weak var buGraph: UIButton!
    @IBOutlet private weak var buSave: UIButton!
    @IBOutlet private weak var buModify: UIButton!
    @IBOutlet private weak var buDelete: UIButton!
    @IBOutlet private weak var buUp: UIButton!
    @IBOutlet private weak var buDown: UIButton!
    @IBOutlet private weak var buExport: UIButton!
    @IBOutlet private weak var buGrade: UIButton!
    @IBOutlet private weak var buSaveAct: UIButton!
    @IBOutlet private weak var buBack: UIButton!
    @IBOutlet private weak var buDeleteActivity: UIButton!
    @IBOutlet private weak var buGraph2: UIButton!
    @IBOutlet private weak var buGroups: UIButton!
    @IBOutlet private weak var buRandy: UIButton!

    @IBOutlet private weak var laTitle: UILabel!
    @IBOutlet private weak var laName: UILabel!
    @IBOutlet private weak var laStudentId: UILabel!
    @IBOutlet private weak var laFirstName: UILabel!
    @IBOutlet private weak var laLastName: UILabel!
    @IBOutlet private weak var laEmail: UILabel!
    @IBOutlet private weak var laGroup: UILabel!
    @IBOutlet private weak var laStudentPerformance: UILabel!

    @IBOutlet private weak var tfClass: UITextField!
    @IBOutlet private weak var tfStudent: UITextField!
    @IBOutlet private weak var tfFirstName: UITextField!
    @IBOutlet private weak var tfLastName: UITextField!
    @IBOutlet private weak var tfEmailName: UITextField!
    @IBOutlet private weak var tfGradeGroup: UITextField!
    @IBOutlet private weak var tfSaveActivity: UITextField!

    @IBOutlet private weak var ivBase: UIImageView!
    @IBOutlet private weak var ivGrupos: UIImageView!
    @IBOutlet private weak var ivAlumnos: UIImageView!
    @IBOutlet private weak var ivActividades: UIImageView!

    @IBOutlet private weak var grafica1: InfoCharts!
    @IBOutlet private weak var grafica2: InfoCharts!

    private var animatedDistance: CGFloat = 0

    private static let keyboardAnimationDuration: CGFloat = 0.3
    private static let minimumScrollFraction: CGFloat = 0.2
    private static let maximumScrollFraction: CGFloat = 0.8
    private static let portraitKeyboardHeight: CGFloat = 265
    private static let landscapeKeyboardHeight: CGFloat = 162

    private var baselocal: DataBase!
    private var sub: Subtitulados!
    private var valores = NSMutableDictionary()

    private var basesDatos: ComboBox!
    private var tGrupos: BasicTable!
    private var tAlumnos: BasicTable!
    private var tActividades: BasicTable!

    private var prefs: UserDefaults!

    private func randy(_ key: String, comment: String) -> String {
        Bundle.main.localizedString(forKey: key, value: nil, table: "RandyLocal")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Force Auto Layout to resolve the placeholder image views' frames now,
        // since the code below copies their .frame into the custom table/combo
        // views below before the normal (deferred) layout pass would run.
        view.layoutIfNeeded()

        // Crear Base Datos default
        valores = NSMutableDictionary()
        sub = Subtitulados()

        let tablasbd: NSArray = ["ESTUDIANTES", "STUDENTID TEXT", "NOMBRE TEXT", "APELLIDO TEXT", "EMAIL TEXT", "PARTICIPACIONES FLOAT"]
        let tablasAR: NSArray = ["GRUPOS", "GRUPONO TEXT", "ALUMNOSID TEXT", "ACTIVIDAD TEXT", "POSICION TEXT", "CALIFICACION FLOAT"]
        let concentracion: NSArray = [tablasbd, tablasAR]

        prefs = UserDefaults.standard

        baselocal = DataBase(file: archivo1 ?? "", tablas: concentracion)

        let bdLocalES: NSArray = ["Id", "Studentid", "Nombre", "Apellido", "Email", "Participaciones"]
        let bdLocalSES: NSArray = ["StudentId", "Nombre", "Apellido", "Email", "Participaciones"]
        valores["BDLocalES"] = bdLocalES
        valores["BDLocalSES"] = bdLocalSES

        let bdLocalGR: NSArray = ["Id", "Grupono", "Alumnosid", "Actividad", "Posicion", "Calificacion"]
        let bdLocalSGR: NSArray = ["Grupono", "Alumnosid", "Actividad", "Posicion", "Calificacion"]
        let bdLocalSTAGR: NSArray = ["Grupono", "Actividad", "Calificacion"]
        valores["BDLocalGR"] = bdLocalGR
        valores["BDLocalSGR"] = bdLocalSGR
        valores["BDLocalSTAGR"] = bdLocalSTAGR

        // Converted (not read directly) because these placeholder image views now
        // sit inside the centered layout wrapper added to the XIB, so their .frame
        // is in that wrapper's coordinate space, not view's.
        tAlumnos = BasicTable()
        tAlumnos.view.frame = ivAlumnos.superview?.convert(ivAlumnos.frame, to: view) ?? ivAlumnos.frame
        tAlumnos.delegadobase = self
        tAlumnos.funcion = 1
        tAlumnos.tamsubtit = 15
        tAlumnos.tamtit = 20
        view.addSubview(tAlumnos.view)
        tAlumnos.cargartablas(sub.titidc1c2subc3c4c5(baselocal.getalltablesfromDB("estudiantes", campos: bdLocalES), c1: "Nombre", c2: "Apellido", c3: "Studentid", c4: "Email", c5: "Participaciones"))

        tGrupos = BasicTable()
        tGrupos.view.frame = ivGrupos.superview?.convert(ivGrupos.frame, to: view) ?? ivGrupos.frame
        tGrupos.delegadobase = self
        tGrupos.funcion = 2
        tGrupos.tamsubtit = 15
        tGrupos.tamtit = 20
        view.addSubview(tGrupos.view)
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(1), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))

        tActividades = BasicTable()
        tActividades.view.frame = ivActividades.superview?.convert(ivActividades.frame, to: view) ?? ivActividades.frame
        tActividades.delegadobase = self
        tActividades.funcion = 3
        tActividades.tamsubtit = 15
        tActividades.tamtit = 20
        view.addSubview(tActividades.view)
        tActividades.cargartablas(sub.titc1subc2c3(baselocal.getalldatafromstatement("SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad,Grupono ASC", campos: bdLocalSTAGR), c1: "Grupono", c2: "Actividad", c3: "Calificacion"))

        valores["IDRandeo"] = "0"
        valores["GrupoNoEvaluar"] = "0"
        valores["ActividadEvaluar"] = "0"

        laStudentPerformance.isHidden = true

        graficdata()
        changerandy(nil)
    }

    // MARK: - Informacion del Seleccionado Tabla

    func setselected(_ seleccion: String, fun: Int32) {
        let idseleccionado = (seleccion as NSString).intValue
        if fun == 1 {
            tfStudent.text = baselocal.getselecteddatafromstatement("SELECT Studentid FROM estudiantes WHERE id=\(idseleccionado)")
            tfFirstName.text = baselocal.getselecteddatafromstatement("SELECT Nombre FROM estudiantes WHERE id=\(idseleccionado)")
            tfLastName.text = baselocal.getselecteddatafromstatement("SELECT Apellido FROM estudiantes WHERE id=\(idseleccionado)")
            tfEmailName.text = baselocal.getselecteddatafromstatement("SELECT Email FROM estudiantes WHERE id=\(idseleccionado)")
        }
        if fun == 2 {
            valores["IDRandeo"] = seleccion
        }
        if fun == 3 {
            let grupos = baselocal.getalldatafromstatement("SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad,Grupono", campos: (valores["BDLocalSTAGR"] as? NSArray) ?? [])
            let seleccionInt = (seleccion as NSString).integerValue
            if let grupono = grupos["Grupono"] as? [Any], seleccionInt - 1 < grupono.count, seleccionInt - 1 >= 0 {
                valores["GrupoNoEvaluar"] = grupono[seleccionInt - 1]
            }
            if let actividad = grupos["Actividad"] as? [Any], seleccionInt - 1 < actividad.count, seleccionInt - 1 >= 0 {
                valores["ActividadEvaluar"] = actividad[seleccionInt - 1]
            }
            tGrupos.cargartablas(sub.titidc1c2subc3c4(consultar((valores["ActividadEvaluar"] as? String) ?? ""), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
        }
    }

    // MARK: - Informacion del Seleccionado ComboBox

    func sendselection(_ sendselection: String, titulo: String) {
        // matches the original: no-op even when titulo == "Archivo"
    }

    private func consultar(_ actividad: String) -> NSDictionary {
        let randybase: NSArray = ["grupono", "alumnosid", "posicion"]
        let dRandyPosicion = baselocal.getalldatafromstatement("SELECT grupono,alumnosid,posicion FROM grupos WHERE actividad=\"\(actividad)\" ORDER BY grupono,posicion ASC", campos: randybase)

        let listafinal = NSMutableDictionary()
        let alumnosids = (dRandyPosicion["alumnosid"] as? [Any]) ?? []
        let grupo = (dRandyPosicion["grupono"] as? [Any]) ?? []
        let posicion = (dRandyPosicion["posicion"] as? [Any]) ?? []

        if !alumnosids.isEmpty {
            var arID: [String] = []
            var arGrupo: [String] = []
            var arPosicion: [String] = []
            var arNombre: [String] = []
            var arStudentid: [String] = []

            for a in 0..<alumnosids.count {
                arID.append("\(a + 1)")
                arGrupo.append("\(grupo[a])")
                let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(alumnosids[a])\" AND posicion=\"\(posicion[a])\" GROUP BY alumnosid")
                arPosicion.append("\(posicion[a])(\(veces))")
                let nombre = baselocal.getselecteddatafromstatement("SELECT nombre FROM estudiantes WHERE studentid=\"\(alumnosids[a])\"")
                let apellido = baselocal.getselecteddatafromstatement("SELECT apellido FROM estudiantes WHERE studentid=\"\(alumnosids[a])\"")
                arNombre.append("\(nombre) \(apellido)")
                arStudentid.append("\(alumnosids[a])")
            }

            listafinal["Id"] = arID
            listafinal["Grupo"] = arGrupo
            listafinal["Posicion"] = arPosicion
            listafinal["Nombre"] = arNombre
            listafinal["Studentid"] = arStudentid
        }

        valores["Randeo"] = listafinal
        return listafinal
    }

    @IBAction private func save(_ sender: Any) {
        guard let studentText = tfStudent.text, !studentText.isEmpty,
              let firstName = tfFirstName.text, !firstName.isEmpty,
              let lastName = tfLastName.text, !lastName.isEmpty,
              let email = tfEmailName.text, !email.isEmpty else { return }

        let estudiante: NSArray = [studentText, firstName, lastName, email, "0"]
        baselocal.revisarBD((valores["BDLocalSES"] as? NSArray) ?? [], valores: estudiante, testigo: "studentid", tabla: "estudiantes", campo: "studentid", nombre: studentText)
        tAlumnos.cargartablas(sub.titidc1c2subc3c4c5(baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? []), c1: "Nombre", c2: "Apellido", c3: "Studentid", c4: "Email", c5: "Participaciones"))

        tfFirstName.text = ""
        tfLastName.text = ""
        tfEmailName.text = ""
        tfStudent.text = ""
    }

    @IBAction private func modify(_ sender: Any) {
        guard let studentText = tfStudent.text, !studentText.isEmpty,
              let firstName = tfFirstName.text, !firstName.isEmpty,
              let lastName = tfLastName.text, !lastName.isEmpty,
              let email = tfEmailName.text, !email.isEmpty else { return }

        baselocal.update("UPDATE estudiantes SET nombre =\"\(firstName)\",apellido =\"\(lastName)\",email =\"\(email)\" WHERE studentid =\"\(studentText)\"")
        tAlumnos.cargartablas(sub.titidc1c2subc3c4c5(baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? []), c1: "Nombre", c2: "Apellido", c3: "Studentid", c4: "Email", c5: "Participaciones"))
    }

    @IBAction private func deleteid(_ sender: Any) {
        baselocal.update("DELETE FROM estudiantes WHERE studentid =\"\(tfStudent.text ?? "")\"")
        tfFirstName.text = ""
        tfLastName.text = ""
        tfEmailName.text = ""
        tfStudent.text = ""
        tAlumnos.cargartablas(sub.titidc1c2subc3c4c5(baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? []), c1: "Nombre", c2: "Apellido", c3: "Studentid", c4: "Email", c5: "Participaciones"))
    }

    /// Fisher-Yates-ish shuffle-by-random-insertion, matching the original's
    /// `arc4random() % (tmpArray.count + 1)` insertion-position technique.
    private func shuffled(_ array: [Any]) -> [Any] {
        var tmpArray: [Any] = []
        for object in array {
            let randomPos = Int(arc4random() % UInt32(tmpArray.count + 1))
            tmpArray.insert(object, at: randomPos)
        }
        return tmpArray
    }

    @IBAction private func group2(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(2), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }
    @IBAction private func group3(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(3), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }
    @IBAction private func group4(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(4), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }
    @IBAction private func group5(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(5), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }
    @IBAction private func group6(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(randear(6), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }

    private func createalumnos(_ arreglo: [Any]) -> NSDictionary {
        var nombre: [String] = []
        var apellido: [String] = []
        var studentId: [String] = []
        for item in arreglo {
            nombre.append(baselocal.getselecteddatafromstatement("SELECT nombre FROM estudiantes WHERE studentid=\"\(item)\""))
            apellido.append(baselocal.getselecteddatafromstatement("SELECT apellido FROM estudiantes WHERE studentid=\"\(item)\""))
            studentId.append("\(item)")
        }
        return ["Nombre": nombre, "Apellido": apellido, "Studentid": studentId]
    }

    /// Random-balanced group assignment ("snake draft"): ranks students by
    /// accumulated grade (when there's grading history), deals them out
    /// top-then-bottom into `entero` groups round-robin style, then
    /// reorders both the groups and each group's internal roles to
    /// minimize repeats against prior activities. Ported as literally as
    /// possible from the original — see the file header note.
    private func randear(_ entero: Int) -> NSDictionary {
        let randybase: NSArray = ["alumnosid", "calificacion"]
        let dRandyBase = baselocal.getalldatafromstatement("SELECT alumnosid,SUM(calificacion) FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC", campos: randybase)

        let dCalificaciones = baselocal.getalldatafromstatement("SELECT calificacion FROM grupos GROUP BY calificacion ORDER BY calificacion DESC", campos: ["calificacion"])

        var tdalumnos: NSDictionary = [:]
        var countal = 0
        let nnalumnos = (dRandyBase["alumnosid"] as? [Any]) ?? []

        var antecedentes = false
        if !nnalumnos.isEmpty {
            // Si existen antecedentes
            if dCalificaciones.count > 1 {
                tdalumnos = createalumnos(nnalumnos)
                countal = (tdalumnos["Nombre"] as? [Any])?.count ?? 0
                antecedentes = true
            } else {
                tdalumnos = baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? [])
                countal = (tdalumnos["Nombre"] as? [Any])?.count ?? 0
                antecedentes = false
            }
        } else {
            // Si no existen antecedentes
            tdalumnos = baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? [])
            countal = (tdalumnos["Nombre"] as? [Any])?.count ?? 0
            antecedentes = false
        }

        var arID: [String] = []
        var arGrupo: [String] = []
        var arPosicion: [String] = []
        var arNombre: [String] = []
        var arStudentid: [String] = []

        if antecedentes {
            let conteo = Float(countal)
            let entero1 = Float(entero)
            let division = conteo / entero1

            var grupos: [[String]] = Array(repeating: [], count: entero)
            let tal = (tdalumnos["Studentid"] as? [Any])?.map { "\($0)" } ?? []
            var nuevos = tal

            if entero1 > 1 {
                if division >= 2 {
                    // Place Tops
                    for a in 0..<entero {
                        if !nuevos.isEmpty {
                            let info = nuevos.removeFirst()
                            grupos[a].append(info)
                        }
                    }
                    // Place Downs
                    for a in 0..<entero {
                        if !nuevos.isEmpty {
                            let info = nuevos.removeLast()
                            grupos[a].append(info)
                        }
                    }
                    let repeticiones = Int((conteo - (entero1 * 2)) / (entero1 * 2))
                    if repeticiones > 0 {
                        for _ in 0..<repeticiones {
                            // Place Tops
                            for a in 0..<entero {
                                if !nuevos.isEmpty {
                                    let info = nuevos.removeFirst()
                                    grupos[a].append(info)
                                }
                            }
                            // Place Downs
                            for a in 0..<entero {
                                if !nuevos.isEmpty {
                                    let info = nuevos.removeLast()
                                    grupos[a].append(info)
                                }
                            }
                        }
                    }
                }
            }

            if Float(nuevos.count) >= entero1 {
                for a in 0..<entero {
                    if !nuevos.isEmpty {
                        let info = nuevos.removeFirst()
                        grupos[a].append(info)
                    }
                }
            }

            var gruposadicionales: [Int] = []
            var testigo = 0
            for g in 0..<entero {
                let idivi = Int(division)
                let objetos = (Int(division) * (g + 1)) - (idivi * (g + 1))
                let real = objetos - testigo
                if real >= 1 {
                    gruposadicionales.append(g + 1)
                    testigo += 1
                }
            }
            if !gruposadicionales.isEmpty {
                for h in 0..<gruposadicionales.count {
                    if !nuevos.isEmpty {
                        let info = nuevos.removeFirst()
                        let tt = gruposadicionales[h] - 1
                        grupos[tt].append(info)
                    }
                }
            }

            // GET RANDY GROUPS VALUE
            if entero1 > 1 {
                var ordengrupos: [[String]] = []
                var gruposn = grupos

                for i in 0..<entero {
                    var maximo = 0
                    var nngrupo = 0
                    if !gruposn.isEmpty {
                        for j in 0..<gruposn.count {
                            var sumatoria = 0
                            let temporal = gruposn[j]
                            for k in 0..<temporal.count {
                                let numGroup = baselocal.getselecteddatafromstatement("SELECT count(grupono) FROM grupos WHERE grupono =\"G\(i + 1)\" AND alumnosid=\"\(temporal[k])\"")
                                sumatoria += (numGroup as NSString).integerValue
                            }
                            if maximo == 0 {
                                maximo = sumatoria
                                nngrupo = j
                            } else if maximo > sumatoria {
                                maximo = sumatoria
                                nngrupo = j
                            }
                        }
                    }
                    ordengrupos.append(gruposn[nngrupo])
                    gruposn.remove(at: nngrupo)
                }

                // GET RANDY ROLES VALUE
                if countal > 0, !ordengrupos.isEmpty {
                    var finalinfo: [[String]] = []
                    for l in 0..<ordengrupos.count {
                        let temporalA = ordengrupos[l]
                        var posicionfinal: [String] = []
                        var ttnuevos = temporalA

                        for m in 0..<temporalA.count {
                            var maximo = 0
                            var nnpart = 0
                            if !ttnuevos.isEmpty {
                                for n in 0..<ttnuevos.count {
                                    let numGroup = baselocal.getselecteddatafromstatement("SELECT count(posicion) FROM grupos WHERE posicion =\"Rol \(m + 1)\" AND alumnosid=\"\(ttnuevos[n])\"")
                                    let numGroupInt = (numGroup as NSString).integerValue
                                    if maximo == 0 {
                                        maximo = numGroupInt
                                        nnpart = n
                                    } else if maximo > numGroupInt {
                                        maximo = numGroupInt
                                        nnpart = n
                                    }
                                }
                            }
                            posicionfinal.append(ttnuevos[nnpart])
                            ttnuevos.remove(at: nnpart)
                        }
                        finalinfo.append(posicionfinal)
                    }

                    var base = 1
                    for z in 0..<finalinfo.count {
                        let tfin = finalinfo[z]
                        for y in 0..<tfin.count {
                            arID.append("\(base)")
                            arGrupo.append("G\(z + 1)")
                            let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(tfin[y])\" AND posicion=\"Rol \(y + 1)\" GROUP BY alumnosid")
                            arPosicion.append("Rol \(y + 1)(\(veces))")
                            let nombre = baselocal.getselecteddatafromstatement("SELECT nombre FROM estudiantes WHERE studentid=\"\(tfin[y])\"")
                            let apellido = baselocal.getselecteddatafromstatement("SELECT apellido FROM estudiantes WHERE studentid=\"\(tfin[y])\"")
                            arNombre.append("\(nombre) \(apellido)")
                            arStudentid.append("\(tfin[y])")
                            base += 1
                        }
                    }
                }
            } else if entero == 1 {
                let alumnid = (tdalumnos["Studentid"] as? [Any])?.map { "\($0)" } ?? []
                for tt in 0..<alumnid.count {
                    arID.append("\(tt + 1)")
                    arGrupo.append("G1")
                    let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(alumnid[tt])\" AND posicion=\"Rol \(tt + 1)\" GROUP BY alumnosid")
                    arPosicion.append("Rol \(tt + 1)(\(veces))")
                    let nombre = baselocal.getselecteddatafromstatement("SELECT nombre FROM estudiantes WHERE studentid=\"\(alumnid[tt])\"")
                    let apellido = baselocal.getselecteddatafromstatement("SELECT apellido FROM estudiantes WHERE studentid=\"\(alumnid[tt])\"")
                    arNombre.append("\(nombre) \(apellido)")
                    arStudentid.append("\(alumnid[tt])")
                }
            }
        } else {
            // Si no existen antecedentes
            if countal > 0 {
                let alumnado = sub.DictoArrayc1c2c3(tdalumnos, c1: "Nombre", c2: "Apellido", c3: "Studentid") as? [Any] ?? []
                let shuf1 = shuffled(alumnado)
                let shuf2 = shuffled(shuf1)
                let conteo = Float(countal)
                let entero1 = Float(entero)
                let division = conteo / entero1
                var e = 0
                for a in 0..<entero {
                    let c = Int(division * Float(a))
                    var d = 0
                    let upper = Int((division * Float(a + 1))) - 1
                    if c <= upper {
                        for b in c...upper {
                            guard b < shuf2.count, let fila = shuf2[b] as? [Any], fila.count >= 3 else { continue }
                            arID.append("\(e + 1)")
                            arGrupo.append("G\(a + 1)")
                            let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(fila[2])\" AND posicion=\"Rol \(d + 1)\" GROUP BY alumnosid")
                            arPosicion.append("Rol \(d + 1)(\(veces))")
                            arNombre.append("\(fila[0]) \(fila[1])")
                            arStudentid.append("\(fila[2])")
                            d += 1
                            e += 1
                        }
                    }
                }
            }
        }

        let listafinal: NSMutableDictionary = ["Id": arID, "Grupo": arGrupo, "Posicion": arPosicion, "Nombre": arNombre, "Studentid": arStudentid]
        valores["Randeo"] = listafinal
        return listafinal
    }

    /// Steps the "who's up" pointer in the current Randeo back one slot,
    /// swapping the previous entry into view (see `back(_:)`/UP button).
    private func goup() -> NSDictionary {
        let upo = NSMutableDictionary()
        var arID: [String] = []
        var arGrupo: [String] = []
        var arPosicion: [String] = []
        var arNombre: [String] = []
        var arStudentid: [String] = []

        guard let randeo = valores["Randeo"] as? NSDictionary else { return upo }
        let aID = (randeo["Id"] as? [Any]) ?? []
        let aGrupo = (randeo["Grupo"] as? [Any]) ?? []
        let aPosicion = (randeo["Posicion"] as? [String]) ?? []
        let aNombre = (randeo["Nombre"] as? [Any]) ?? []
        let aStudentId = (randeo["Studentid"] as? [Any]) ?? []

        let conteovalores = aID.count
        guard conteovalores > 0 else { return upo }

        let idRandeo = ((valores["IDRandeo"] as? String) as NSString?)?.integerValue ?? 0

        if idRandeo > 1 {
            for b in 0..<conteovalores {
                let idB = (("\(aID[b])") as NSString).integerValue
                if idB == idRandeo - 1 {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = b + 1 < aStudentId.count ? baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b + 1])\" AND posicion=\"\(id)\" GROUP BY alumnosid ") : ""
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append(b + 1 < aNombre.count ? "\(aNombre[b + 1])" : "")
                    arStudentid.append(b + 1 < aStudentId.count ? "\(aStudentId[b + 1])" : "")
                } else if idB == idRandeo {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = b - 1 >= 0 ? baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b - 1])\" AND posicion=\"\(id)\"  GROUP BY alumnosid ") : ""
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append(b - 1 >= 0 ? "\(aNombre[b - 1])" : "")
                    arStudentid.append(b - 1 >= 0 ? "\(aStudentId[b - 1])" : "")
                } else {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b])\" AND posicion=\"\(id)\" GROUP BY alumnosid")
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append("\(aNombre[b])")
                    arStudentid.append("\(aStudentId[b])")
                }
            }
            valores["IDRandeo"] = "\(idRandeo - 1)"
        } else {
            for b in 0..<conteovalores {
                arID.append("\(aID[b])")
                arGrupo.append("\(aGrupo[b])")
                let id = posicionPrefix(aPosicion[b])
                let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b])\" AND posicion=\"\(id)\" GROUP BY alumnosid")
                arPosicion.append("\(id)(\(veces))")
                arNombre.append("\(aNombre[b])")
                arStudentid.append("\(aStudentId[b])")
            }
            valores["IDRandeo"] = "\(idRandeo)"
        }

        upo["Id"] = arID
        upo["Grupo"] = arGrupo
        upo["Posicion"] = arPosicion
        upo["Nombre"] = arNombre
        upo["Studentid"] = arStudentid

        valores["Randeo"] = upo
        return upo
    }

    private func godown() -> NSDictionary {
        let upo = NSMutableDictionary()
        var arID: [String] = []
        var arGrupo: [String] = []
        var arPosicion: [String] = []
        var arNombre: [String] = []
        var arStudentid: [String] = []

        guard let randeo = valores["Randeo"] as? NSDictionary else { return upo }
        let aID = (randeo["Id"] as? [Any]) ?? []
        let aGrupo = (randeo["Grupo"] as? [Any]) ?? []
        let aPosicion = (randeo["Posicion"] as? [String]) ?? []
        let aNombre = (randeo["Nombre"] as? [Any]) ?? []
        let aStudentId = (randeo["Studentid"] as? [Any]) ?? []

        let conteovalores = aID.count
        guard conteovalores > 0 else { return upo }

        let idRandeo = ((valores["IDRandeo"] as? String) as NSString?)?.integerValue ?? 0

        if idRandeo <= conteovalores - 1 {
            for b in 0..<conteovalores {
                let idB = (("\(aID[b])") as NSString).integerValue
                if idB == idRandeo + 1 {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = b - 1 >= 0 ? baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b - 1])\" AND posicion=\"\(id)\" GROUP BY alumnosid") : ""
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append(b - 1 >= 0 ? "\(aNombre[b - 1])" : "")
                    arStudentid.append(b - 1 >= 0 ? "\(aStudentId[b - 1])" : "")
                } else if idB == idRandeo {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = b + 1 < aStudentId.count ? baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b + 1])\" AND posicion=\"\(id)\" GROUP BY alumnosid") : ""
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append(b + 1 < aNombre.count ? "\(aNombre[b + 1])" : "")
                    arStudentid.append(b + 1 < aStudentId.count ? "\(aStudentId[b + 1])" : "")
                } else {
                    arID.append("\(aID[b])")
                    arGrupo.append("\(aGrupo[b])")
                    let id = posicionPrefix(aPosicion[b])
                    let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b])\" AND posicion=\"\(id)\" GROUP BY alumnosid")
                    arPosicion.append("\(id)(\(veces))")
                    arNombre.append("\(aNombre[b])")
                    arStudentid.append("\(aStudentId[b])")
                }
            }
            valores["IDRandeo"] = "\(idRandeo + 1)"
        } else {
            for b in 0..<conteovalores {
                arID.append("\(aID[b])")
                arGrupo.append("\(aGrupo[b])")
                let id = posicionPrefix(aPosicion[b])
                let veces = baselocal.getselecteddatafromstatement("SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"\(aStudentId[b])\" AND posicion=\"\(id)\" GROUP BY alumnosid")
                arPosicion.append("\(id)(\(veces))")
                arNombre.append("\(aNombre[b])")
                arStudentid.append("\(aStudentId[b])")
            }
            valores["IDRandeo"] = "\(idRandeo)"
        }

        upo["Id"] = arID
        upo["Grupo"] = arGrupo
        upo["Posicion"] = arPosicion
        upo["Nombre"] = arNombre
        upo["Studentid"] = arStudentid

        valores["Randeo"] = upo
        return upo
    }

    /// "Rol 2(3)" -> "Rol 2" — everything before the first "(".
    private func posicionPrefix(_ posicion: String) -> String {
        guard let range = posicion.range(of: "(") else { return posicion }
        return String(posicion[posicion.startIndex..<range.lowerBound])
    }

    @IBAction private func group1(_ sender: Any) {
        let participantId = valores["ParticipantID"] ?? ""
        let participaciones = baselocal.getselecteddatafromstatement("SELECT participaciones FROM estudiantes WHERE id=\"\(participantId)\"")
        let total = Float((participaciones as NSString).intValue) + 1
        baselocal.update("UPDATE estudiantes SET participaciones =\"\(total)\" WHERE id =\"\(participantId)\"")
        tAlumnos.cargartablas(sub.titidc1c2subc3c4c5(baselocal.getalltablesfromDB("estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? []), c1: "Nombre", c2: "Apellido", c3: "Studentid", c4: "Email", c5: "Participaciones"))
    }

    // MARK: - Funciones

    @IBAction private func newclass(_ sender: Any) {
    }

    @IBAction private func newrandy(_ sender: Any) {
        var tdalumnos: NSDictionary = [:]
        let participaciones = (baselocal.getselecteddatafromstatement("SELECT MAX(participaciones) FROM estudiantes") as NSString).floatValue
        if participaciones == 0 {
            tdalumnos = baselocal.getalldatafromstatement("SELECT * FROM estudiantes", campos: (valores["BDLocalES"] as? NSArray) ?? [])
        } else {
            tdalumnos = baselocal.getalldatafromstatement("SELECT * FROM estudiantes WHERE participaciones<\"\(participaciones)\"", campos: (valores["BDLocalES"] as? NSArray) ?? [])
        }
        let countal = (tdalumnos["Nombre"] as? [Any])?.count ?? 0
        if countal > 0 {
            let alumnado = sub.DictoArrayc1c2c3(tdalumnos, c1: "Id", c2: "Nombre", c3: "Apellido") as? [Any] ?? []
            let shuf1 = shuffled(alumnado)
            let shuf2 = shuffled(shuf1)
            let shuf3 = shuffled(shuf2)
            if let shuf4 = shuf3.first as? [Any], shuf4.count >= 3 {
                laTitle.text = "\(shuf4[0])_\(shuf4[1]) \(shuf4[2])"
                valores["ParticipantID"] = shuf4[0]
            }
        } else {
            tdalumnos = baselocal.getalldatafromstatement("SELECT * FROM estudiantes WHERE participaciones=\"\(participaciones)\"", campos: (valores["BDLocalES"] as? NSArray) ?? [])
            let alumnado = sub.DictoArrayc1c2c3(tdalumnos, c1: "Id", c2: "Nombre", c3: "Apellido") as? [Any] ?? []
            let shuf1 = shuffled(alumnado)
            let shuf2 = shuffled(shuf1)
            let shuf3 = shuffled(shuf2)
            if let shuf4 = shuf3.first as? [Any], shuf4.count >= 3 {
                laTitle.text = "\(shuf4[0])_\(shuf4[1]) \(shuf4[2])"
                valores["ParticipantID"] = shuf4[0]
            }
        }
    }

    @IBAction private func edition(_ sender: Any) {
        // GRUPO EDICION
        buSave.isHidden = false
        buModify.isHidden = false
        buDelete.isHidden = false
        laStudentId.isHidden = false
        laFirstName.isHidden = false
        laLastName.isHidden = false
        laEmail.isHidden = false
        tfStudent.isHidden = false
        tfFirstName.isHidden = false
        tfLastName.isHidden = false
        tfEmailName.isHidden = false
        ivAlumnos.isHidden = false
        tAlumnos.view.isHidden = false

        if UIDevice.current.userInterfaceIdiom == .phone {
            // GRUPO RANDY
            ivGrupos.isHidden = true
            tGrupos.view.isHidden = true
            tfSaveActivity.isHidden = true
            buSaveAct.isHidden = true
            buUp.isHidden = true
            buDown.isHidden = true

            // GRUPO GRUPO
            laGroup.isHidden = true
            buDeleteActivity.isHidden = true
            tfGradeGroup.isHidden = true
            buGrade.isHidden = true
            ivActividades.isHidden = true
            tActividades.view.isHidden = true
        } else {
            // GRUPO RANDY
            ivGrupos.isHidden = false
            tGrupos.view.isHidden = false
            tfSaveActivity.isHidden = false
            buSaveAct.isHidden = false
            buUp.isHidden = false
            buDown.isHidden = false

            // GRUPO GRUPO
            laGroup.isHidden = false
            tfGradeGroup.isHidden = false
            buGrade.isHidden = false
            buDeleteActivity.isHidden = false
            ivActividades.isHidden = false
            tActividades.view.isHidden = false
        }

        laStudentPerformance.isHidden = true
        grafica1.isHidden = true
        grafica2.isHidden = true
    }

    @IBAction private func graphs(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            setEditionHidden(true)
            setRandyHidden(true)
            setGrupoHidden(true, includingActividades: true)
            laStudentPerformance.isHidden = true
            grafica1.isHidden = false
            grafica2.isHidden = true
        } else {
            setEditionHidden(true)
            setGrupoHidden(true, includingActividades: true)
            laStudentPerformance.isHidden = false
            grafica1.isHidden = false
            grafica2.isHidden = false
        }
    }

    @IBAction private func changegroups(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            setEditionHidden(true)
            setRandyHidden(true)
            laGroup.isHidden = false
            buDeleteActivity.isHidden = false
            ivActividades.isHidden = false
            tActividades.view.isHidden = false
            tfGradeGroup.isHidden = false
            buGrade.isHidden = false

            laStudentPerformance.isHidden = true
            grafica1.isHidden = true
            grafica2.isHidden = true
        } else {
            // NON APPLING RESOURCE
        }
    }

    @IBAction private func graphs2(_ sender: Any) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            setEditionHidden(true)
            setRandyHidden(true)
            setGrupoHidden(true, includingActividades: true)
            laStudentPerformance.isHidden = true
            grafica1.isHidden = true
            grafica2.isHidden = false
        } else {
            setGrupoHidden(true, includingActividades: true)
            laStudentPerformance.isHidden = false
            grafica1.isHidden = false
            grafica2.isHidden = false
        }
    }

    @IBAction private func changerandy(_ sender: Any?) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            setEditionHidden(true)
            laGroup.isHidden = true
            buDeleteActivity.isHidden = true
            ivActividades.isHidden = true
            tActividades.view.isHidden = true
            tfGradeGroup.isHidden = true
            buGrade.isHidden = true

            ivGrupos.isHidden = false
            tGrupos.view.isHidden = false
            tfSaveActivity.isHidden = false
            buSaveAct.isHidden = false
            buUp.isHidden = false
            buDown.isHidden = false

            laStudentPerformance.isHidden = true
            grafica1.isHidden = true
            grafica2.isHidden = true
        } else {
            setEditionHidden(false)

            ivGrupos.isHidden = false
            tGrupos.view.isHidden = false
            tfSaveActivity.isHidden = false
            buSaveAct.isHidden = false
            buUp.isHidden = false
            buDown.isHidden = false

            laGroup.isHidden = false
            buDeleteActivity.isHidden = false
            ivActividades.isHidden = false
            tActividades.view.isHidden = false
            tfGradeGroup.isHidden = false
            buGrade.isHidden = false

            laStudentPerformance.isHidden = true
            grafica1.isHidden = true
            grafica2.isHidden = true
        }
    }

    /// Shared by graphs/changegroups/graphs2/changerandy: the "Edicion" (student
    /// roster editing) group of controls.
    private func setEditionHidden(_ hidden: Bool) {
        buSave.isHidden = hidden
        buModify.isHidden = hidden
        buDelete.isHidden = hidden
        laStudentId.isHidden = hidden
        laFirstName.isHidden = hidden
        laLastName.isHidden = hidden
        laEmail.isHidden = hidden
        tfStudent.isHidden = hidden
        tfFirstName.isHidden = hidden
        tfLastName.isHidden = hidden
        tfEmailName.isHidden = hidden
        ivAlumnos.isHidden = hidden
        tAlumnos.view.isHidden = hidden
    }

    /// Shared "Randy" (random-group) group of controls.
    private func setRandyHidden(_ hidden: Bool) {
        ivGrupos.isHidden = hidden
        tGrupos.view.isHidden = hidden
        tfSaveActivity.isHidden = hidden
        buSaveAct.isHidden = hidden
        buUp.isHidden = hidden
        buDown.isHidden = hidden
    }

    /// Shared "Grupo" (activity grading) group of controls.
    private func setGrupoHidden(_ hidden: Bool, includingActividades: Bool) {
        laGroup.isHidden = hidden
        buDeleteActivity.isHidden = hidden
        if includingActividades {
            ivActividades.isHidden = hidden
            tActividades.view.isHidden = hidden
        }
        tfGradeGroup.isHidden = hidden
        buGrade.isHidden = hidden
    }

    @IBAction private func deleteactivity(_ sender: Any) {
        baselocal.update("DELETE FROM grupos WHERE actividad =\"\((valores["ActividadEvaluar"] as? String) ?? "")\"")
        tActividades.cargartablas(sub.titc1subc2c3(baselocal.getalldatafromstatement("SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad", campos: (valores["BDLocalSTAGR"] as? NSArray) ?? []), c1: "Grupono", c2: "Actividad", c3: "Calificacion"))
        graficdata()
    }

    @IBAction private func upup(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(goup(), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }

    @IBAction private func down(_ sender: Any) {
        tGrupos.cargartablas(sub.titidc1c2subc3c4(godown(), c1: "Grupo", c2: "Nombre", c3: "Posicion", c4: "Studentid"))
    }

    @IBAction private func exportdata(_ sender: Any) {
    }

    @IBAction private func gradegroup(_ sender: Any) {
        if let text = tfGradeGroup.text, !text.isEmpty {
            let ssgrupono = (valores["GrupoNoEvaluar"] as? String) ?? ""
            let ssactividad = (valores["ActividadEvaluar"] as? String) ?? ""
            let calificacion = (text as NSString).floatValue
            baselocal.update("UPDATE grupos SET calificacion =\"\(calificacion)\" WHERE grupono =\"\(ssgrupono)\" AND actividad =\"\(ssactividad)\" ")
            graficdata()
        }
        tActividades.cargartablas(sub.titc1subc2c3(baselocal.getalldatafromstatement("SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad", campos: (valores["BDLocalSTAGR"] as? NSArray) ?? []), c1: "Grupono", c2: "Actividad", c3: "Calificacion"))
        graficdata()
    }

    private func graficdata() {
        let rpg1: NSArray = ["actividad"]
        let drpg1 = baselocal.getalldatafromstatement("SELECT actividad FROM grupos GROUP BY actividad ORDER BY actividad ASC", campos: rpg1)
        let rpg1a: NSArray = ["actividad", "ccalificacion", "scalificacion"]
        let drpg1a = baselocal.getalldatafromstatement("SELECT actividad,COUNT(actividad),SUM(calificacion) FROM grupos GROUP BY actividad ORDER BY actividad ASC", campos: rpg1a)
        let rpg1c: NSArray = ["alumnosid", "actividad", "calificacion"]
        let drpg1c = baselocal.getalldatafromstatement("SELECT alumnosid,actividad,SUM(calificacion) FROM grupos GROUP BY alumnosid,actividad ORDER BY actividad,alumnosid ASC", campos: rpg1c)
        let extgra1: NSArray = ["Campos", "Acumulado", "Campo", "Valor"]

        grafica1.rectangulos = sub.subgraf(drpg1, acumulados: drpg1a, campos: drpg1c, info: rpg1, info2: rpg1a, info3: rpg1c, info4: extgra1)
        grafica1.updateview()

        let rpg2: NSArray = ["alumnosid"]
        let drpg2 = baselocal.getalldatafromstatement("SELECT alumnosid FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC", campos: rpg2)
        let rpg2a: NSArray = ["alumnosid", "ccalificacion", "scalificacion"]
        let drpg2a = baselocal.getalldatafromstatement("SELECT alumnosid,COUNT(posicion),SUM(calificacion) FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC", campos: rpg2a)
        let rpg2c: NSArray = ["posicion", "alumnosid", "calificacion"]
        let drpg2c = baselocal.getalldatafromstatement("SELECT posicion,alumnosid,SUM(calificacion) FROM grupos GROUP BY posicion,alumnosid ORDER BY SUM(calificacion) DESC", campos: rpg2c)
        let extgra2: NSArray = ["Campos", "Acumulado", "Campo", "Valor"]

        grafica2.rectangulos = sub.subgraf(drpg2, acumulados: drpg2a, campos: drpg2c, info: rpg2, info2: rpg2a, info3: rpg2c, info4: extgra2)
        grafica2.updateview()
    }

    @IBAction private func saveactivity(_ sender: Any) {
        if let text = tfSaveActivity.text, !text.isEmpty {
            if let randeo = valores["Randeo"] as? NSDictionary {
                let aID = (randeo["Id"] as? [Any]) ?? []
                let aGrupo = (randeo["Grupo"] as? [Any]) ?? []
                let aPosicion = (randeo["Posicion"] as? [String]) ?? []
                let aStudentId = (randeo["Studentid"] as? [Any]) ?? []
                let conteo = aID.count
                if conteo > 0 {
                    for a in 0..<conteo {
                        let id = posicionPrefix(aPosicion[a])
                        let grupos: NSArray = [aGrupo[a], aStudentId[a], text, id, "0"]
                        baselocal.revisarBD2T((valores["BDLocalSGR"] as? NSArray) ?? [], valores: grupos, testigo: "id", tabla: "grupos", campo: "actividad", nombre: text, campo2: "alumnosid", nombre2: "\(aStudentId[a])")
                    }
                }
            }

            tActividades.cargartablas(sub.titc1subc2c3(baselocal.getalldatafromstatement("SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad", campos: (valores["BDLocalSTAGR"] as? NSArray) ?? []), c1: "Grupono", c2: "Actividad", c3: "Calificacion"))

            tfSaveActivity.text = ""
        }
        graficdata()
    }

    @IBAction private func back(_ sender: Any) {
        delegatem?.classesDidFinish(self)
    }

    // MARK: - Textfields edition

    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let window = view.window else { return }
        let textFieldRect = window.convert(textField.bounds, from: textField)
        let viewRect = window.convert(view.bounds, from: view)
        let midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height
        let numerator = midline - viewRect.origin.y - Classes.minimumScrollFraction * viewRect.size.height
        let denominator = (Classes.maximumScrollFraction - Classes.minimumScrollFraction) * viewRect.size.height
        var heightFraction = denominator == 0 ? 0 : numerator / denominator
        if heightFraction < 0.0 {
            heightFraction = 0.0
        } else if heightFraction > 1.0 {
            heightFraction = 1.0
        }

        let orientation = UIApplication.shared.statusBarOrientation
        if orientation == .portrait || orientation == .portraitUpsideDown {
            animatedDistance = floor(Classes.portraitKeyboardHeight * heightFraction)
        } else {
            animatedDistance = floor(Classes.landscapeKeyboardHeight * heightFraction)
        }

        var viewFrame = view.frame
        viewFrame.origin.y -= animatedDistance

        UIView.animate(withDuration: Classes.keyboardAnimationDuration, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.frame = viewFrame
        })
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var viewFrame = view.frame
        viewFrame.origin.y += animatedDistance

        UIView.animate(withDuration: Classes.keyboardAnimationDuration, delay: 0, options: [.beginFromCurrentState], animations: {
            self.view.frame = viewFrame
        })
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
