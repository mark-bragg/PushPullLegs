//
//  PPLButton.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/1/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class ExerciseTypeButton : UILabel {
    let exerciseType: ExerciseTypeName
    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? .black : .quaternary }
    }
    
    init(exerciseType: ExerciseTypeName) {
        self.exerciseType = exerciseType
        super.init(frame: .zero)
        text = exerciseType.rawValue
        textAlignment = .center
        isHighlighted = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
