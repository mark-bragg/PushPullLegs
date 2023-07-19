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
        UIColor.systemBackground
    }
    static var secondary: UIColor {
        UIColor.secondarySystemBackground
    }
    static var tertiary: UIColor {
        UIColor.tertiarySystemBackground
    }
    static var quaternary: UIColor {
        UIColor.quaternarySystemFill
    }
    static var text: UIColor {
        UITextField.appearance().tintColor = .white
        UITextField.appearance().textColor = .white
        return .white
    }
    
    static let pplArrowGreen = UIColor(named: "ppl_arrow_green")!
    static let pplArrowRed = UIColor(named: "ppl_arrow_red")!
    
    static func primaryWithColor(_ name: String) -> UIColor {
        UIColor(named: "\(name)_primary") ?? .black
    }
}
