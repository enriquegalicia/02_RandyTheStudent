//
//  BasicTable.swift
//  RandyTheStudent
//
//  Swift port of the original BasicTable.m (Objective-C) — a small
//  reusable UITableViewController used as an embedded subview (its
//  `.view` gets manually re-parented; see Classes.m). Loads BasicTable.xib
//  via the standard "nib name matches class name" convention, which is
//  why `@objc(BasicTable)` matters here, not just for ObjC interop:
//  NSStringFromClass(self) has to come back as "BasicTable" for that nib
//  lookup to find the file.
//
//  `@objc(basictable)` on the delegate protocol keeps Classes.h's (still
//  Objective-C, until it's converted) `<basictable, ComboDelegate>`
//  conformance declaration compiling unchanged.
//
//  One deliberate change: `delegadobase` was `retain` (strong) in the
//  original, which is a real retain cycle (Classes owns TAlumnos/TGrupos/
//  TActividades strongly, and each held Classes strongly right back via
//  this delegate). Made it `weak`, standard Cocoa delegate practice and
//  harmless here since Classes always outlives these child controllers.
//

import UIKit

@objc(basictable)
protocol BasicTableDelegate: NSObjectProtocol {
    @objc(setselected:fun:)
    func setselected(_ seleccion: String, fun: Int32)
}

@objc(BasicTable)
class BasicTable: UITableViewController {

    @objc weak var delegadobase: BasicTableDelegate?
    @objc var tamtit: Int32 = 0
    @objc var tamsubtit: Int32 = 0
    @objc var funcion: Int32 = 0
    @objc var informacion: NSDictionary?

    private var titulo: [Any] = []
    private var titulo2: [Any] = []
    private var subtitulo: [Any] = []
    private var subtitulo2: [Any] = []
    private var cantidaddeelementos = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        cantidaddeelementos = 0
    }

    @objc(cargartablas:)
    func cargartablas(_ informacion: NSDictionary) {
        titulo = (informacion["Titulo"] as? [Any]) ?? []
        titulo2 = titulo
        subtitulo = (informacion["Subtitulo"] as? [Any]) ?? []
        subtitulo2 = subtitulo

        cantidaddeelementos = titulo2.count
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cantidaddeelementos > 0 ? cantidaddeelementos : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CountryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)

        let tituloss = indexPath.row < titulo2.count ? "\(titulo2[indexPath.row])" : ""
        cell.textLabel?.text = tituloss
        cell.textLabel?.lineBreakMode = .byCharWrapping
        cell.textLabel?.numberOfLines = 1
        cell.textLabel?.font = UIFont(name: "Futura-CondensedMedium", size: CGFloat(tamtit))
        cell.backgroundColor = .white

        let subtituloss = indexPath.row < subtitulo.count ? "\(subtitulo[indexPath.row])" : ""
        cell.detailTextLabel?.text = subtituloss
        cell.detailTextLabel?.numberOfLines = 2
        cell.detailTextLabel?.font = UIFont(name: "Futura-CondensedMedium", size: CGFloat(tamsubtit))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        let text = cell.textLabel?.text ?? ""
        if let range = text.range(of: "_") {
            let id = String(text[text.startIndex..<range.lowerBound])
            delegadobase?.setselected(id, fun: funcion)
        } else {
            delegadobase?.setselected(text, fun: funcion)
        }
    }
}
