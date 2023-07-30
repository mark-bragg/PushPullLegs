//
//  AssetIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/10/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

typealias PPLColor = UIColor

extension PPLColor {
    static let pplOffWhite = UIColor(named: "ppl_off_white")
    static let pplGray = UIColor(named: "ppl_gray")
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
}
