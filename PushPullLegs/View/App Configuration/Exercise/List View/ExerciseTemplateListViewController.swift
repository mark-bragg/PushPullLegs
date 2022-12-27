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

class ExerciseTemplateListViewController: PPLTableViewController, UIAdaptivePresentationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.allowsSelection = false
    }
    
    private var exerciseTemplateListViewModel: ExerciseTemplateListViewModel? {
        viewModel as? ExerciseTemplateListViewModel
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = sectionHeaderTitle(section) else {
            return nil
        }
        let headerView = tableHeaderViewContainer(titles: [title], section: section)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = sectionHeaderTitle(section) != nil ? super.tableView(tableView, heightForHeaderInSection: section) : 0
        return height
    }
    
    func sectionHeaderTitle(_ section: Int) -> String? {
        guard let viewModel = viewModel, viewModel.rowCount(section: section) > 0 else { return nil }
        return exerciseTemplateListViewModel?.titleForSection(section)
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        guard let exerciseTemplateListViewModel else { return }
        let vc = ExerciseTemplateCreationViewController()
        vc.showExerciseType = true
        vc.viewModel = ExerciseTemplateCreationViewModel(management: exerciseTemplateListViewModel.templateManagement)
        vc.presentationController?.delegate = self
        vc.viewModel?.reloader = self
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as? PPLTableViewCell,
            let rootView = cell.rootView
        else { return PPLTableViewCell() }
        var textLabel = rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textAlignment = .center
            textLabel?.textColor = PPLColor.text
            rootView.addSubview(textLabel!)
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: 0).isActive = true
        }
        textLabel?.text = viewModel?.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            exerciseTemplateListViewModel?.deleteExercise(indexPath: indexPath)
            reload()
        }
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PPLTableViewCell else { return }
        cell.setHighlighted(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let ip = indexPath, let cell = tableView.cellForRow(at: ip) as? PPLTableViewCell else { return }
        cell.setHighlighted(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func reload() {
        exerciseTemplateListViewModel?.reload()
        tableView?.reloadData()
        super.reload()
    }
    
}
