//
//  AssetIdentifiers.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/10/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class AssetIdentifier {
    private init() {
        
    }
}

class PPLColor: AssetIdentifier {
    static let green = UIColor(named: "ppl_green")
    static let tableGreen = UIColor(named: "ppl_green_table")
    static let grey = UIColor(named: "ppl_grey")
    static let lightGrey = UIColor(named: "ppl_light_grey")
    static let darkGreen = UIColor(named: "ppl_dark_green")
    static let textBlue = UIColor(named: "ppl_text_blue")
    static let darkGrey = UIColor(named: "ppl_dark_grey")
    static let darkGreyText = UIColor(named: "ppl_dark_grey_text")
    static let disabledSaveWhiteColor: UIColor = UIColor(white: 0.75, alpha: 0.5)
    static let offWhite = UIColor(named: "ppl_off_white")
}
