//
//  Credits.swift
//  RandyTheStudent
//
//  Swift port of the original Credits.m (Objective-C). Loads Credits.xib
//  via the "nib name matches class name" convention; `@objc(Credits)` is
//  what makes that (and the not-yet-converted RandyMenu.h/.m's use of
//  this class) keep working.
//
//  `@objc(CreditsDelegate)` on the delegate protocol keeps RandyMenu.h's
//  `<..., CreditsDelegate>` conformance declaration compiling unchanged.
//
//  One deliberate change: `delegatec` was `assign` in the original, i.e.
//  an unsafe unretained back-reference under ARC (can dangle if the
//  delegate is freed first). Made it `weak`, which nils itself out
//  safely instead.
//
//  The tap-to-dismiss gesture here is done the old way (compare
//  touch.view against the "back" label in touchesBegan) rather than a
//  UITapGestureRecognizer/UIButton, to keep this a faithful line-for-line
//  port; worth modernizing in a later cleanup pass.
//

import UIKit

@objc(CreditsDelegate)
protocol CreditsDelegate: NSObjectProtocol {
    @objc(CreditsDidFinish:)
    func creditsDidFinish(_ controller: Credits)
}

@objc(Credits)
class Credits: UIViewController {

    @objc weak var delegatec: CreditsDelegate?
    @IBOutlet private weak var back: UILabel!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        preferredContentSize = CGSize(width: 320, height: 480)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event?.allTouches?.first, touch.view == back {
            delegatec?.creditsDidFinish(self)
        }
    }
}
