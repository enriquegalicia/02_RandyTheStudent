//
//  ComboBox.swift
//  RandyTheStudent
//
//  Swift port of the original ComboBox.m (Objective-C), a small
//  UIPickerView-backed dropdown control (originally by Dor Alon,
//  http://doralon.net). Loads ComboBox.xib via the "nib name matches
//  class name" convention, and that nib's customClass="ComboBox" +
//  action/outlet wiring is why `@objc(ComboBox)` is required here, not
//  just for interop with the not-yet-converted Objective-C callers
//  (RandyMenu.h/.m).
//
//  `@objc(ComboDelegate)` on the delegate protocol keeps RandyMenu.h's
//  and Classes.h's `<ComboDelegate, ...>` conformance declarations
//  compiling unchanged until those files are converted too.
//
//  One deliberate change: `delegadocombo` was `retain` (strong) in the
//  original — a retain cycle, since the owning view controller also
//  holds this ComboBox strongly. Made it `weak`, standard delegate
//  practice, harmless here.
//

import UIKit

@objc(ComboDelegate)
protocol ComboDelegate: NSObjectProtocol {
    @objc(sendselection:titulo:)
    func sendselection(_ sendselection: String, titulo: String)
}

@objc(ComboBox)
class ComboBox: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @objc weak var delegadocombo: ComboDelegate?
    @objc var activo: Int32 = 0
    @objc var titulo: String = ""
    @objc var selectedText: String = ""
    @objc @IBOutlet var textField: UITextField!
    @IBOutlet private weak var flecha: UIImageView!

    private var pickerView: UIPickerView?
    private var dataArray: NSMutableArray = []

    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = "\(dataArray[row])"
        textField.text = text
        selectedText = text
        if activo == 1 {
            delegadocombo?.sendselection(text, titulo: titulo)
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(dataArray[row])"
    }

    @objc func textinside() -> String {
        textField.text ?? ""
    }

    // MARK: - ComboBox

    @objc(setComboData:)
    func setComboData(_ data: NSMutableArray) {
        dataArray = data
    }

    @objc(text:)
    func text(_ texto: String) {
        textField.text = texto
        selectedText = texto
    }

    @objc func hide() {
        textField.isHidden = true
        flecha.isHidden = true
    }

    @objc func show() {
        textField.isHidden = false
        flecha.isHidden = false
    }

    @objc func valordeltexto() -> String {
        textField.text ?? ""
    }

    @objc private func doneClicked(_ sender: Any) {
        textField.resignFirstResponder() // hides the pickerView
    }

    @IBAction func showPicker(_ sender: Any) {
        let picker = UIPickerView()
        picker.showsSelectionIndicator = true
        picker.dataSource = self
        picker.delegate = self
        pickerView = picker

        let toolbar = UIToolbar()
        toolbar.barStyle = .blackTranslucent
        toolbar.sizeToFit()

        // to make the done button aligned to the right
        let flexibleSpaceLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked(_:)))
        toolbar.items = [flexibleSpaceLeft, doneButton]

        // custom input view
        textField.inputView = picker
        textField.inputAccessoryView = toolbar
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showPicker(textField)
        return true
    }
}
