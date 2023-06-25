//
//  ExerciseListViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/15/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class ExerciseTemplateListViewController: PPLTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ExerciseTemplateListViewModel(withTemplateManagement: TemplateManagement())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.allowsSelection = false
        setupRightBarButtonItems()
    }
    
    override func getRightBarButtonItems() -> [UIBarButtonItem] {
        [addButtonItem()]
    }
    
    private var exerciseTemplateListViewModel: ExerciseTemplateListViewModel? {
        viewModel as? ExerciseTemplateListViewModel
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        reload()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sectionCount?() ?? 0
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
    
    override func addAction() {
        super.addAction()
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
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier)
        else { return UITableViewCell() }
        let contentView = cell.contentView
        var textLabel = contentView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.textAlignment = .center
            textLabel?.textColor = PPLColor.text
            contentView.addSubview(textLabel!)
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -10).isActive = true
            textLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        }
        textLabel?.text = viewModel?.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        exerciseTemplateListViewModel?.deleteExercise(indexPath: indexPath)
        reload()
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.setHighlighted(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let ip = indexPath, let cell = tableView.cellForRow(at: ip) else { return }
        cell.setHighlighted(false, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    override func reload() {
        exerciseTemplateListViewModel?.reload()
        tableView?.reloadData()
        super.reload()
    }
    
}
