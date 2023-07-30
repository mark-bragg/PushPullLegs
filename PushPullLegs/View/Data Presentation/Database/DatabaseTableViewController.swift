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
        get { viewModel as? DatabaseViewModel ?? DatabaseViewModel() }
        set { viewModel = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupRightBarButtonItems()
    }
    
    @objc
    func edit() {
        let isEditing = !(tableView?.isEditing ?? false)
        tableView?.setEditing(isEditing, animated: false)
        if isEditing, let viewModel = viewModel {
            navigationItem.rightBarButtonItems = nil
            navigationItem.rightBarButtonItem = viewModel.hasData() ? UIBarButtonItem(barButtonSystemItem: isEditing ? .done : .edit, target: self, action: #selector(edit)) : nil
        } else {
            setupRightBarButtonItems()
        }
        tableView?.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        dbTblViewModel?.objectToDelete = indexPath
        presentDeleteConfirmation(self, indexPath: indexPath)
    }
    
    @objc
    func presentDeleteConfirmation(_ sender: Any, indexPath: IndexPath) {
        guard let dbTblViewModel else { return }
        let alert = UIAlertController.init(title: dbTblViewModel.deletionAlertTitle(), message: dbTblViewModel.deletionAlertMessage(indexPath), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { action in
            dbTblViewModel.deleteDatabaseObject()
            self.reload()
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private var dbTblViewModel: DatabaseViewModel? {
        viewModel as? DatabaseViewModel
    }
    
    override func reload() {
        super.reload()
        if let tblv = tableView, tblv.isEditing, let vm = viewModel, !vm.hasData() {
            edit()
        }
    }
    
    override func getRightBarButtonItems() -> [UIBarButtonItem] {
        let addBtnItem = addButtonItem()
        if let vm = viewModel, vm.hasData() {
            let editBtnItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
            editBtnItem.accessibilityIdentifier = .edit
            return [addBtnItem, editBtnItem]
        } else {
            return [addBtnItem]
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        tableView.isEditing
    }
}
