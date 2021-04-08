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
        setupRightBarButtonItems()
    }
    
    @objc override func edit(_ sender: Any?) {
        let isEditing = !tableView.isEditing
        tableView.setEditing(isEditing, animated: false)
        if isEditing {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = viewModel.rowCount(section: 0) == 0 ? nil : UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit(_:)))
        } else {
            setupRightBarButtonItems()
        }
        tableView.reloadData()
    }
    
    private func setupRightBarButtonItems() {
        let addBtnItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))
        let editBtnItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit(_:)))
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = [addBtnItem, editBtnItem]
    }
    
    override func exerciseSetViewModelStartedSet(_ viewModel: ExerciseSetViewModel) {
        let dvc = DurationCollectionViewController()
        dvc.exerciseSetViewModel = exerciseSetViewModel
        setNavController.pushViewController(dvc, animated: true)
    }
}
