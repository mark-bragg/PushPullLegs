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
    
    init(name: String, otherNames: [String], type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = ExerciseGraphViewModel(name: name, otherNames: otherNames, type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func names() -> [String] {
        return exerciseGraphViewModel.otherNames
    }
    
    override func didSelectName(_ name: String) {
        dismiss(animated: true) { [unowned self] in
            let oldName = exerciseGraphViewModel.title()
            let oldOtherNames = exerciseGraphViewModel.otherNames
            var newOtherNames = oldOtherNames.filter({$0 != name})
            newOtherNames.append(oldName)
            let newVm = ExerciseGraphViewModel(name: name, otherNames: newOtherNames, type: exerciseGraphViewModel.type)
            viewModel = newVm
            view.setNeedsLayout()
////            navigationItem.title = name
//            navigationItem.t
//            navigationController?.title = name
            reloadViews()
            setTitleLabel()
        }
    }
    
}
