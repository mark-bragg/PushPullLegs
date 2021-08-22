//
//  ExerciseSelectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

protocol ExerciseTemplateSelectionDelegate: NSObject {
    func exerciseTemplatesAdded()
}

class ExerciseTemplateSelectionViewController: PPLTableViewController {
    weak var delegate: ExerciseTemplateSelectionDelegate?
    var selectedIndices = [Int]()
    var exerciseSelectionViewModel: ExerciseSelectionViewModel { viewModel as! ExerciseSelectionViewModel }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: exerciseCellReuseIdentifier)
        tableView?.allowsMultipleSelection = true
        navigationItem.title = "Select Exercises"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExercise))
    }
    
    @objc override func pop() {
        super.pop()
        guard exerciseSelectionViewModel.selectedExercises().count > 0 else { return }
        exerciseSelectionViewModel.commitChanges()
        delegate?.exerciseTemplatesAdded()
    }
    
    @objc func addExercise() {
        let vc = ExerciseTemplateCreationViewController()
        vc.showExerciseType = false
        vc.viewModel = ExerciseTemplateCreationViewModel(withType: exerciseSelectionViewModel.exerciseType, management: TemplateManagement())
        vc.viewModel?.reloader = self
        vc.modalPresentationStyle = .pageSheet
        vc.presentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.multiSelect = viewModel?.multiSelect ?? false
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textColor = PPLColor.text
            textLabel?.textAlignment = .center
            cell.rootView.addSubview(textLabel!)
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor, constant: 0).isActive = true
        }
        textLabel!.text = exerciseSelectionViewModel.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            // TODO: refactor to new method in ExerciseSelectionViewModel: func toggle()
            if exerciseSelectionViewModel.isSelected(row: indexPath.row) {
                exerciseSelectionViewModel.deselected(row: indexPath.row)
                cell.setSelected(false, animated: true)
            } else {
                exerciseSelectionViewModel.selected(row: indexPath.row)
                cell.setSelected(true, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableHeaderViewContainer(titles: ["Select Exercises To Add"])
    }
    
    override func reload() {
        exerciseSelectionViewModel.reload()
        tableView?.reloadData()
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.exerciseTemplateSelectionVC
    }
}

extension ExerciseTemplateSelectionViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
    }
}
