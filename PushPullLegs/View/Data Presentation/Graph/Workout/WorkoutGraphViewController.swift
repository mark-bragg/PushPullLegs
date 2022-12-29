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
    
    override func dropdownItems() -> [PPLDropdownItem] {
        var items = [PPLDropdownItem]()
        if let exerciseItems = workoutGraphViewModel?.getExerciseNames().map({ name in
            PPLDropdownItem(target: nil, action: nil, name: name)
        }) {
            items.append(PPLDropdownNavigationItem(items: exerciseItems, name: "Exercises"))
        }
        if let dateItem = dateNavigationItem() {
            items.append(dateItem)
        }
        return items
    }
    
    override func didSelectItem(_ item: PPLDropdownItem) {
        dismiss(animated: true) {
            guard let vm = self.workoutGraphViewModel else { return }
            let vc = ExerciseGraphViewController(name: item.name, otherNames: vm.getExerciseNames().filter({$0 != item.name}), type: vm.type)
            vc.viewModel?.startDate = vm.startDate
            vc.viewModel?.endDate = vm.endDate
            self.isNavigatingToExercise = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

class WorkoutGraphCellViewController: WorkoutGraphViewController {
    override var backgroundColor: UIColor { .clear }
}
