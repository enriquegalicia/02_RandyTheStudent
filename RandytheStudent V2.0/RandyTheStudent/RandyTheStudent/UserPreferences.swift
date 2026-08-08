//
//  UserPreferences.swift
//  RandyTheStudent
//
//  Swift port of the original UserPreferences.m (Objective-C).
//  NOTE: not currently instantiated anywhere in the app (verified via
//  project-wide search before porting) — kept for parity with the
//  original codebase in case something is later wired up to it.
//
//  `@objc` is kept so any not-yet-converted Objective-C file can still
//  call this exactly as before while the rest of the app migrates.
//

import Foundation

@objc(UserPreferences)
class UserPreferences: NSObject {

    @objc var baseInicial: String = ""
    @objc var password: String = ""
    @objc var acceso: Bool = false
    @objc var entero: Int = 0
    @objc var idUsuario: String = ""

    private let prefs = UserDefaults.standard

    @objc func initwithdefaults() -> UserPreferences {
        if prefs.string(forKey: "Usuario") == nil {
            prefs.set("", forKey: "Usuario")
        }
        if prefs.string(forKey: "Password") == nil {
            prefs.set("", forKey: "Password")
        }
        if prefs.string(forKey: "Entero") == nil {
            prefs.set(0, forKey: "Entero")
        }
        if prefs.string(forKey: "ID") == nil {
            prefs.set(0, forKey: "ID")
        }

        baseInicial = prefs.string(forKey: "BaseInicial") ?? ""
        password = prefs.string(forKey: "Password") ?? ""
        entero = Int(prefs.string(forKey: "Entero") ?? "") ?? 0
        idUsuario = prefs.string(forKey: "ID") ?? ""

        return self
    }

    @objc(setoBaseInicial:)
    func setoBaseInicial(_ baseInicial1: String) {
        prefs.set(baseInicial1, forKey: "BaseInicial")
        baseInicial = prefs.string(forKey: "BaseInicial") ?? ""
    }

    @objc(setoPassword:)
    func setoPassword(_ usuario1: String) {
        prefs.set(usuario1, forKey: "Password")
        password = prefs.string(forKey: "Password") ?? ""
    }

    @objc(setoEntero:)
    func setoEntero(_ entero1: Int) {
        prefs.set(entero1, forKey: "Entero")
        entero = Int(prefs.string(forKey: "Entero") ?? "") ?? 0
    }

    @objc(setoIDD:)
    func setoIDD(_ idd: String) {
        prefs.set(idd, forKey: "ID")
        idUsuario = prefs.string(forKey: "ID") ?? ""
    }

    @objc func getoBaseInicial() -> String {
        prefs.string(forKey: "BaseInicial") ?? ""
    }

    @objc func getoPassword() -> String {
        prefs.string(forKey: "Usuario") ?? ""
    }

    @objc func getoEntero() -> Int32 {
        Int32(prefs.string(forKey: "Entero") ?? "") ?? 0
    }

    @objc func getoID() -> String {
        prefs.string(forKey: "ID") ?? ""
    }
}
