//
//  PPLButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/1/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class ExerciseTypeButton : UIButton {
    var exerciseType: ExerciseTypeName? = nil
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(origin: CGPoint.zero, size: size))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(colorImage, for: forState)
    }
}
