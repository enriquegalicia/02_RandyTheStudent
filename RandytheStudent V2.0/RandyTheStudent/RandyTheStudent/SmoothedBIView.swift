//
//  SmoothedBIView.swift
//  RandyTheStudent
//
//  Swift port of the original SmoothedBIView.m (Objective-C) — Apple's
//  classic smoothed freehand Bezier drawing view.
//  NOTE: not referenced by any XIB or instantiated anywhere in the app
//  (verified via project-wide search before porting) — kept for parity
//  with the original codebase.
//

import UIKit

class SmoothedBIView: UIView {

    private var path = UIBezierPath()
    private var incrementalImage: UIImage?
    // Four points of a Bezier segment, plus the first control point of the next segment.
    private var pts = [CGPoint](repeating: .zero, count: 5)
    private var ctr = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = false
        backgroundColor = .white
        path.lineWidth = 15
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = false
        path.lineWidth = 15
    }

    override func draw(_ rect: CGRect) {
        incrementalImage?.draw(in: rect)
        path.stroke()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ctr = 0
        if let touch = touches.first {
            pts[0] = touch.location(in: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let p = touch.location(in: self)
        ctr += 1
        pts[ctr] = p
        if ctr == 4 {
            // move the endpoint to the middle of the line joining the second control
            // point of the first Bezier segment and the first control point of the second
            pts[3] = CGPoint(x: (pts[2].x + pts[4].x) / 2.0, y: (pts[2].y + pts[4].y) / 2.0)

            path.move(to: pts[0])
            path.addCurve(to: pts[3], controlPoint1: pts[1], controlPoint2: pts[2])

            setNeedsDisplay()
            // replace points and get ready to handle the next segment
            pts[0] = pts[3]
            pts[1] = pts[4]
            ctr = 1
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawBitmap()
        setNeedsDisplay()
        path.removeAllPoints()
        ctr = 0
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        defer { UIGraphicsEndImageContext() }

        if incrementalImage == nil {
            // first time; paint background white
            let rectPath = UIBezierPath(rect: bounds)
            UIColor.white.setFill()
            rectPath.fill()
        }
        incrementalImage?.draw(at: .zero)
        UIColor.black.setStroke()
        path.stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
    }
}
