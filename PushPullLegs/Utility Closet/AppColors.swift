//
//  AssetIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/10/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

typealias PPLColor = UIColor

class ColorNames {
    static let black = "black"
    static let red = "red"
    static let green = "green"
    static let blue = "blue"
    static let purple = "purple"
    
    static let list = [black, red, green, blue, purple]
}

extension PPLColor {
    static let pplOffWhite = UIColor(named: "ppl_off_white")
    static let disabledSaveWhiteColor: UIColor = UIColor(white: 0.75, alpha: 0.75)
    static let readyStatePlusSign: UIColor = UIColor(white: 0.85, alpha: 1)
    static let pressedStatePlusSign: UIColor = UIColor(white: 0.33, alpha: 1)
    
    static let pplGray = UIColor(named: "ppl_gray")
    static let pplLightGray = UIColor(named: "ppl_light_gray")
    static let pplDarkGray = UIColor(named: "ppl_dark_gray")
    static let pplDarkGrayText = UIColor(named: "ppl_dark_gray_text")
    
    static var primary: UIColor {
        primaryWithColor(PPLDefaults.instance.getDefaultColor())
    }
    static var secondary: UIColor {
        UIColor(named: "\(PPLDefaults.instance.getDefaultColor())_secondary") ?? UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
    static var tertiary: UIColor {
        UIColor(named: "\(PPLDefaults.instance.getDefaultColor())_tertiary") ?? .darkGray
    }
    static var quaternary: UIColor {
        UIColor(named: "\(PPLDefaults.instance.getDefaultColor())_quaternary") ?? .gray
    }
    static var text: UIColor {
        let color = UIColor(named: "\(PPLDefaults.instance.getDefaultColor())_text") ?? .white
        UITextField.appearance().tintColor = color
        UITextField.appearance().textColor = color
        return color
    }
    
    static let pplArrowGreen = UIColor(named: "ppl_arrow_green")!
    static let pplArrowRed = UIColor(named: "ppl_arrow_red")!
    
    static func primaryWithColor(_ name: String) -> UIColor {
        UIColor(named: "\(name)_primary") ?? .black
    }
}

@objc protocol DefaultColorUpdateResponder: NSObjectProtocol {
    @objc func handleDefaultColorUpdate()
}

class DefaultColorUpdate {
    private static var observers: Set<NSObject> = Set()
    
    static func addObserver(_ responder: DefaultColorUpdateResponder) {
        guard let responder = responder as? NSObject else { return }
        observers.insert(responder)
    }
    
    static func notifyObservers() {
        for observer in observers {
            if let observer = observer as? DefaultColorUpdateResponder {
                observer.handleDefaultColorUpdate()
            }
        }
    }
}
