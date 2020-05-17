//
//  UITableViewCell+ExerciseDataCell.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/16/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    func setWorkoutProgressionImage(_ comparison: ExerciseVolumeComparison) {
        var imageName: String
        var tint: UIColor
        if comparison == .increase {
            imageName = "arrow.up"
            tint = .green
        } else {
            imageName = "arrow.down"
            tint = .red
        }
        imageView?.image = UIImage.init(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
        imageView?.tintColor = tint
    }
}
