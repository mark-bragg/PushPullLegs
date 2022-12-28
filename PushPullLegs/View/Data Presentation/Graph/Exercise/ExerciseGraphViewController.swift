//
//  ExerciseGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseGraphViewController: GraphViewController {

    var exerciseGraphViewModel: ExerciseGraphViewModel? { viewModel as? ExerciseGraphViewModel }
    
    init(name: String, otherNames: [String], type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = ExerciseGraphViewModel(name: name, otherNames: otherNames, type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func dropdownItems() -> [PPLDropdownItem] {
        if let exerciseItems = exerciseGraphViewModel?.otherNames.map({ name in
            PPLDropdownItem(target: nil, action: nil, name: name)
        }) {
            return
            [
                PPLDropdownNavigationItem(items: exerciseItems, name: "Exercises")
            ]
        }
        return []
    }
    
    override func didSelectItem(_ item: PPLDropdownItem) {
        dismiss(animated: true) { [weak self] in
            guard
                let exerciseGraphViewModel = self?.exerciseGraphViewModel
            else { return }
            let oldName = exerciseGraphViewModel.title()
            let oldOtherNames = exerciseGraphViewModel.otherNames
            var newOtherNames = oldOtherNames.filter({$0 != item.name})
            newOtherNames.append(oldName)
            let newVm = ExerciseGraphViewModel(name: item.name, otherNames: newOtherNames, type: exerciseGraphViewModel.type)
            self?.viewModel = newVm
            self?.reloadViews()
            self?.setTitleLabel()
        }
    }
    
}
