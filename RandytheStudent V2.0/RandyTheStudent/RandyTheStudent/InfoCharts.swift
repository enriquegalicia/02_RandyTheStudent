//
//  InfoCharts.swift
//  RandyTheStudent
//
//  Swift port of the original InfoCharts.m (Objective-C) — a simple
//  hand-rolled horizontal stacked-bar chart view, driven by the
//  dictionary shape Subtitulados.subgraf(...) produces (keys "Campos",
//  "Acumulado", "Campo", "Valor").
//
//  `@objc(InfoCharts)` is required (not just a nicety) — both
//  MainViewController_iPhone.xib and MainViewController_iPad.xib
//  reference this class by the bare name "InfoCharts" in their
//  customClass attribute, and that string lookup only succeeds if a
//  class is registered under that exact Objective-C runtime name.
//

import UIKit

@objc(InfoCharts)
class InfoCharts: UIView {

    @objc var rectangulos: NSDictionary?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = false
        backgroundColor = .clear
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
    }

    override func draw(_ rect: CGRect) {
        let campos = (rectangulos?["Campos"] as? [Any]) ?? []
        let acumulado = (rectangulos?["Acumulado"] as? [Any]) ?? []
        let campo = (rectangulos?["Campo"] as? [Any]) ?? []
        let valor = (rectangulos?["Valor"] as? [Any]) ?? []

        for v in subviews {
            v.removeFromSuperview()
        }

        let altototal = Float(rect.size.height)
        let divisiones = campos.isEmpty ? 0 : altototal / Float(campos.count)

        if !campos.isEmpty {
            for a in 0..<campos.count {
                let nombre = UILabel()
                nombre.text = "\(campos[a])"
                nombre.frame = CGRect(x: 0, y: 0, width: 100, height: CGFloat(divisiones - 10))
                nombre.center = CGPoint(x: 50, y: CGFloat(divisiones / 2 + 5 + Float(a) * divisiones))
                nombre.minimumScaleFactor = 0.5
                nombre.adjustsFontSizeToFitWidth = true
                addSubview(nombre)
            }
        }

        var maximo: Float = 0.0
        for a in acumulado {
            let v = numeric(a)
            if maximo < v { maximo = v }
        }
        let pixval = maximo == 0 ? 0 : (Float(rect.size.width) - 100) / maximo

        // Create background
        for a in 0..<acumulado.count {
            let path = UIBezierPath()
            path.lineWidth = 1
            drawrectangles(path, posicion: CGRect(
                x: 100,
                y: CGFloat(Float(a) * divisiones),
                width: CGFloat(100 + numeric(acumulado[a]) * pixval),
                height: CGFloat(divisiones + Float(a) * divisiones)
            ))

            UIColor.lightGray.setFill()
            UIColor.black.setStroke()
            path.close()
            path.fill()
            path.stroke()
        }

        for a in 0..<campo.count {
            guard let campoRow = campo[a] as? [Any], let valorRow = valor[a] as? [Any] else { continue }
            var base: Float = 100
            var azul: Float = 1
            var rojo: Float = 1
            var verde: Float = 1

            for b in 0..<campoRow.count {
                let path = UIBezierPath()
                path.lineWidth = 1

                let ancho = numeric(valorRow[b]) * pixval
                drawrectangles(path, posicion: CGRect(
                    x: CGFloat(base),
                    y: CGFloat(Float(a) * divisiones),
                    width: CGFloat(base + ancho),
                    height: CGFloat(divisiones + Float(a) * divisiones)
                ))
                base += ancho

                azul -= 0.05
                if azul < 0 { azul += 1 }
                verde -= 0.10
                if verde < 0 { verde += 1 }
                rojo -= 0.15
                if rojo < 0 { rojo += 1 }

                UIColor(red: CGFloat(rojo), green: CGFloat(verde), blue: CGFloat(azul), alpha: 1).setFill()
                UIColor.black.setStroke()
                path.close()
                path.fill()
                path.stroke()
            }
        }
    }

    private func drawrectangles(_ pato: UIBezierPath, posicion: CGRect) {
        pato.move(to: CGPoint(x: posicion.origin.x, y: posicion.origin.y))
        pato.addLine(to: CGPoint(x: posicion.size.width, y: posicion.origin.y))
        pato.addLine(to: CGPoint(x: posicion.size.width, y: posicion.size.height))
        pato.addLine(to: CGPoint(x: posicion.origin.x, y: posicion.size.height))
    }

    @objc func updateview() {
        setNeedsDisplay()
    }

    /// Mirrors Objective-C's lenient `-[NSString floatValue]` (parses a
    /// leading numeric prefix, 0 if none) rather than Swift's strict
    /// `Float(String)` (nil unless the whole string parses).
    private func numeric(_ value: Any) -> Float {
        ("\(value)" as NSString).floatValue
    }
}
