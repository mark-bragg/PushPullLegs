//
//  DBExerciseViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/2/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class DBExerciseViewController: ExerciseViewController {
    override func viewWillAppear(_ animated: Bool) {
        readOnly = true
        super.viewWillAppear(animated)
    }
    
    @objc override func edit() {
        let isEditing = !(tableView?.isEditing ?? true)
        tableView?.setEditing(isEditing, animated: false)
        if isEditing {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = dbViewModel.hasData() ? UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit)) : nil
        } else {
            setupRightBarButtonItems()
        }
        tableView?.reloadData()
    }
    
    override func exerciseSetViewModelWillStartSet(_ viewModel: ExerciseSetViewModel) {
        let dvc = DurationCollectionViewController()
        dvc.exerciseSetViewModel = exerciseSetViewModel
        setNavController?.pushViewController(dvc, animated: true)
    }
    
    override func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel) {
        super.exerciseSetViewModelFinishedSet(viewModel)
        setupRightBarButtonItems()
    }
    
    override func setupRestTimerView() {
        // no op
    }
}
