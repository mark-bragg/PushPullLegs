//
//  WorkoutGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class WorkoutGraphViewController: GraphViewController {

    var workoutGraphViewModel: WorkoutGraphViewModel? { viewModel as? WorkoutGraphViewModel }
    private var frame: CGRect?
    private var isNavigatingToExercise = false
    
    init(type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = WorkoutGraphViewModel(type: type)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let frame = frame {
            view.frame = frame
        }
        isNavigatingToExercise = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isNavigatingToExercise {
            rotateBackToPortrait()
        }
    }
    
    override func names() -> [String] {
        workoutGraphViewModel?.getExerciseNames() ?? []
    }
    
    override func didSelectName(_ name: String) {
        dismiss(animated: true) {
            guard let vm = self.workoutGraphViewModel else { return }
            let vc = ExerciseGraphViewController(name: name, otherNames: vm.getExerciseNames().filter({$0 != name}), type: vm.type)
            self.isNavigatingToExercise = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
