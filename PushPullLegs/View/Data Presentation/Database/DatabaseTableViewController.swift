//
//  DatabaseTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import Foundation
import UIKit

class DatabaseTableViewController: PPLTableViewController {
    
    var dbViewModel: DatabaseViewModel {
        get { viewModel as! DatabaseViewModel }
        set { viewModel = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRightBarButtonItems()
    }
    
    @objc func edit(_ sender: Any?) {
        let isEditing = !(tableView?.isEditing ?? false)
        tableView?.setEditing(isEditing, animated: false)
        if isEditing, let viewModel = viewModel {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = viewModel.rowCount(section: 0) == 0 ? nil : UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit(_:)))
        } else {
            setupRightBarButtonItems()
        }
        tableView?.reloadData()
        if let btn = addButton {
            btn.isHidden = isEditing
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dbTblViewModel.objectToDelete = indexPath
        presentDeleteConfirmation(self)
    }
    
    @objc func presentDeleteConfirmation(_ sender: Any) {
        let alert = UIAlertController.init(title: dbTblViewModel.deletionAlertTitle(), message: dbTblViewModel.deletionAlertMessage(), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { action in
            self.dbTblViewModel.deleteDatabaseObject()
            self.reload()
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private var dbTblViewModel: DatabaseViewModel {
        viewModel as! DatabaseViewModel
    }
    
    override func reload() {
        super.reload()
        if let tblv = tableView, tblv.isEditing, let vm = viewModel, vm.rowCount(section: 0) == 0 {
            edit(self)
        }
    }
    
    func setupRightBarButtonItems() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItems = getRightBarButtonItems()
    }
    
    func getRightBarButtonItems() -> [UIBarButtonItem] {
        let addBtnItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))
        navigationItem.rightBarButtonItem = nil
        if let vm = viewModel, vm.rowCount(section: 0) == 0 {
            return [addBtnItem]
        } else {
            let editBtnItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit(_:)))
            return [addBtnItem, editBtnItem]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableView.isEditing
    }
}
