//
//  RandyMenu.swift
//  RandyTheStudent
//
//  Swift port of the original RandyMenu.m (Objective-C) — the main menu
//  screen (pick/create/rename a class, open it, show credits).
//  `@objc(RandyMenu)` is required: both RandyMenu.xib (iPad) and
//  RandyMenu_Iphone.xib load via the "nib name matches class name"
//  convention, and AppDelegate.m (still Objective-C until it's converted
//  too) instantiates this class directly by name.
//

import UIKit

@objc(RandyMenu)
class RandyMenu: UIViewController, ComboDelegate, ClassesDelegate, CreditsDelegate {

    @IBOutlet private weak var lclases: UIButton!
    @IBOutlet private weak var nuevaClase: UITextField!
    @IBOutlet private weak var nueva: UIButton!
    @IBOutlet private weak var rename: UIButton!
    @IBOutlet private weak var creditsButton: UIButton!
    @IBOutlet private weak var ivBase: UIImageView!

    private var basedeBases: DataBase!
    private var basesDatos: ComboBox!
    private var valores = NSMutableDictionary()
    private var prefs: UserDefaults!
    private var sub: Subtitulados!

    private func randy(_ key: String, comment: String) -> String {
        Bundle.main.localizedString(forKey: key, value: nil, table: "RandyLocal")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Force Auto Layout to resolve ivBase's frame now, since it gets copied
        // into basesDatos.view.frame below before the deferred layout pass would run.
        view.layoutIfNeeded()
        sub = Subtitulados()
        valores = NSMutableDictionary()

        // Crear Campos de Base Principal
        let tablaarchivos = ["ARCHIVOS", "NOMBRE TEXT", "ARCHITEXT TEXT"]
        let concentrado = [tablaarchivos]

        // Crear Base Principal
        basedeBases = DataBase(file: "Principal2.db", tablas: concentrado as NSArray)

        let bdPrincipal: NSArray = ["Id", "Nombre", "Architext"]
        let bdPrincipalS: NSArray = ["Nombre", "Architext"]

        let valoresIniciales: NSArray = ["Default", "Default2.db"]
        valores["BDPrincipal"] = bdPrincipal
        valores["BDPrincipalS"] = bdPrincipalS

        let existingIds = (basedeBases.getalltablesfromDB("archivos", campos: bdPrincipal)["Id"] as? [Any]) ?? []
        if existingIds.isEmpty {
            basedeBases.revisarBD(bdPrincipalS, valores: valoresIniciales, testigo: "Nombre", tabla: "archivos", campo: "Nombre", nombre: "Default")
        }

        prefs = UserDefaults.standard
        var strCat = prefs.string(forKey: "Archivo")
        if strCat == nil {
            prefs.set("Default2.db", forKey: "Archivo")
        }
        strCat = prefs.string(forKey: "Archivo")
        valores["NArchivo"] = strCat
        let narchivo = basedeBases.getselecteddatafromstatement("SELECT nombre FROM archivos WHERE architext=\"\(valores["NArchivo"] ?? "")\"")

        basesDatos = ComboBox()
        basesDatos.delegadocombo = self
        basesDatos.activo = 1
        basesDatos.titulo = "Archivo"
        // Converted (not read directly) because ivBase now sits inside the
        // centered layout wrapper added to the XIB, so its .frame is in that
        // wrapper's coordinate space, not view's.
        basesDatos.view.frame = ivBase.superview?.convert(ivBase.frame, to: view) ?? ivBase.frame
        view.addSubview(basesDatos.view)
        basesDatos.text(narchivo)

        basesDatos.setComboData(sub.MAtitc1(basedeBases.getalltablesfromDB("archivos", campos: bdPrincipal), c1: "Nombre"))

        let datosArchivo = basedeBases.getalldatafromstatement("SELECT * FROM archivos WHERE architext=\"\(strCat ?? "")\"", campos: bdPrincipal)
        let nombreArchivo = sub.titc1(datosArchivo, c1: "Nombre")
        basesDatos.text(nombreArchivo)
        valores["NArchivo"] = nombreArchivo
        valores["Archivo"] = basedeBases.getselecteddatafromstatement("SELECT architext FROM archivos WHERE nombre=\"\(valores["NArchivo"] ?? "")\"")
    }

    // MARK: - Informacion del Seleccionado ComboBox

    func sendselection(_ sendselection: String, titulo: String) {
        guard titulo == "Archivo" else { return }
        valores["NArchivo"] = sendselection
        let archivo = basedeBases.getselecteddatafromstatement("SELECT architext FROM archivos WHERE nombre=\"\(valores["NArchivo"] ?? "")\"")
        valores["Archivo"] = archivo
        prefs.set(archivo, forKey: "Archivo")
        nuevaClase.text = sendselection
    }

    @objc(ClassesDidFinish:)
    func classesDidFinish(_ controller: Classes!) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func enterclass(_ sender: Any) {
        let clase: Classes
        if UIDevice.current.userInterfaceIdiom == .phone {
            clase = Classes(nibName: "MainViewController_iPhone", bundle: nil)
        } else {
            clase = Classes(nibName: "MainViewController_iPad", bundle: nil)
        }

        clase.delegatem = self
        clase.archivo1 = valores["Archivo"] as? String

        present(clase, animated: true, completion: nil)
    }

    @IBAction private func newclass(_ sender: Any) {
        guard let text = nuevaClase.text, !text.isEmpty else { return }
        let informacion: NSArray = [text, "\(text).db"]
        basedeBases.revisarBD((valores["BDPrincipalS"] as? NSArray) ?? [], valores: informacion, testigo: "nombre", tabla: "archivos", campo: "nombre", nombre: text)
        basesDatos.setComboData(sub.MAtitc1(basedeBases.getalltablesfromDB("archivos", campos: (valores["BDPrincipal"] as? NSArray) ?? []), c1: "Nombre"))
    }

    @IBAction private func renameclass(_ sender: Any) {
        guard let text = nuevaClase.text, !text.isEmpty else { return }
        let idd = basedeBases.getselecteddatafromstatement("SELECT id FROM archivos WHERE nombre=\"\(basesDatos.selectedText)\"")
        basedeBases.update("UPDATE archivos SET nombre =\"\(text)\" WHERE id =\"\(idd)\"")
        basesDatos.setComboData(sub.MAtitc1(basedeBases.getalltablesfromDB("archivos", campos: (valores["BDPrincipal"] as? NSArray) ?? []), c1: "Nombre"))

        valores["NArchivo"] = text
        let archivo = basedeBases.getselecteddatafromstatement("SELECT architext FROM archivos WHERE nombre=\"\(valores["NArchivo"] ?? "")\"")
        valores["Archivo"] = archivo
        prefs.set(archivo, forKey: "Archivo")
        basesDatos.text(text)
    }

    func creditsDidFinish(_ controller: Credits) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func credits(_ sender: Any) {
        if presentedViewController != nil {
            dismiss(animated: true, completion: nil)
            return
        }
        let credits = Credits(nibName: "Credits", bundle: nil)
        credits.delegatec = self
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(credits, animated: true, completion: nil)
        } else {
            credits.modalPresentationStyle = .popover
            credits.popoverPresentationController?.sourceView = view
            credits.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 320, height: 480)
            credits.popoverPresentationController?.permittedArrowDirections = .right
            present(credits, animated: true, completion: nil)
        }
    }

    /// Not part of ClassesDelegate (only ClassesDidFinish: is) and never called
    /// from Classes — kept for parity with the original, which also never called it.
    func mainDidFinish(_ controller: Classes) {
        dismiss(animated: false, completion: nil)
    }
}
