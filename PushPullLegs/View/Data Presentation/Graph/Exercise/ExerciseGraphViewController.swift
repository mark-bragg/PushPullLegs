//
//  ExerciseGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseGraphViewController: GraphViewController {

    var exerciseGraphViewModel: ExerciseGraphViewModel { viewModel as! ExerciseGraphViewModel }
    
    init(name: String, type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = ExerciseGraphViewModel(name: name, type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
