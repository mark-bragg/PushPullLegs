//
//  ExerciseListViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

fileprivate let PushTag = 1
fileprivate let PullTag = 2
fileprivate let LegsTag = 3

class ExerciseTemplateListViewController: PPLTableViewController, ReloadProtocol, UIAdaptivePresentationControllerDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
        setupAddButton()
        tableView.allowsSelection = false
    }
    
    private func exerciseTemplateListViewModel() -> ExerciseTemplateListViewModel {
        return viewModel as! ExerciseTemplateListViewModel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.createTemplateExercise,
            let vc = segue.destination as? ExerciseTemplateCreationViewController {
            vc.showExerciseType = true
            vc.viewModel = ExerciseTemplateCreationViewModel(management: exerciseTemplateListViewModel().templateManagement)
            vc.presentationController?.delegate = self
            vc.viewModel?.reloader = self
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = exerciseTemplateListViewModel().titleForSection(section) else {
            return nil
        }
        let headerView = tableHeaderView(titles: [title])
        return headerView
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        performSegue(withIdentifier: SegueIdentifier.createTemplateExercise, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textAlignment = .center
            cell.rootView.addSubview(textLabel!)
            cell.selectionStyle = .none
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor, constant: 0).isActive = true
        }
        textLabel?.text = viewModel.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exerciseTemplateListViewModel().deleteExercise(indexPath: indexPath)
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func reload() {
        exerciseTemplateListViewModel().reload()
        tableView.reloadData()
    }
    
}
