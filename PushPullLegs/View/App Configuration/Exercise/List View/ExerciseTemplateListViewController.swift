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
    
    private var creationType: ExerciseType?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
    }
    
    private func exerciseTemplateListViewModel() -> ExerciseTemplateListViewModel {
        return viewModel as! ExerciseTemplateListViewModel
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.createTemplateExercise,
            let vc = segue.destination as? ExerciseTemplateCreationViewController,
            let type = creationType {
            vc.showExerciseType = false
            vc.viewModel = ExerciseTemplateCreationViewModel(withType: type, management: exerciseTemplateListViewModel().templateManagement)
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
        let createLabel = PPLNameLabel()
        createLabel.tag = section + 1
        createLabel.font = UIFont.systemFont(ofSize: 18)
        createLabel.text = "Create"
        createLabel.sizeToFit()
        createLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(createLabel)
        createLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20).isActive = true
        createLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        createLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(create(_:))))
        createLabel.isUserInteractionEnabled = true
        return headerView
    }
    
    @objc func create(_ gr: UITapGestureRecognizer) {
        switch gr.view!.tag {
        case 1:
            creationType = .push
        case 2:
            creationType = .pull
        default:
            creationType = .legs
        }
        performSegue(withIdentifier: SegueIdentifier.createTemplateExercise, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        var textLabel = cell.greenBackground.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textAlignment = .center
            cell.greenBackground.addSubview(textLabel!)
            cell.selectionStyle = .none
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: cell.greenBackground.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.greenBackground.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: cell.greenBackground.centerYAnchor, constant: 0).isActive = true
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
