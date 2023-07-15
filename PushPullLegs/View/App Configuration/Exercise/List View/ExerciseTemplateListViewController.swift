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
        reload()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vm = exerciseTemplateListViewModel?.templateEditViewModel(indexPath: indexPath) else { return }
        vm.reloader = self
        let vc = ExerciseTemplateEditViewController()
        vc.showExerciseType = true
        vc.viewModel = vm
        present(vc, animated: true) {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    override func reload() {
        exerciseTemplateListViewModel?.reload()
        tableView?.reloadData()
        super.reload()
    }
}

class ExerciseTemplateEditViewController: ExerciseTemplateCreationViewController {
    private var editVM: ExerciseTemplateEditViewModel? { viewModel as? ExerciseTemplateEditViewModel }
    
    override func loadView() {
        view = ExerciseTemplateEditView()
    }
    
    override func handleViewDidLayoutSubviews() {
        guard let editVM else { return }
        creationView.textField.text = editVM.exerciseName
        highlightTypes(editVM.originalTypes)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        creationView.saveButton.isEnabled = true
    }
}

class ExerciseTemplateEditViewModel: ExerciseTemplateCreationViewModel {
    private let template: ExerciseTemplate
    let originalTypes: [ExerciseTypeName]
    override var titleLabel: String { "Edit Exercise" }
    
    init?(template: ExerciseTemplate, management: TemplateManagement) {
        guard let types = template.types?.allObjects as? [ExerciseType] else { return nil }
        self.template = template
        var originalTypes = [ExerciseTypeName]()
        for type in types {
            guard let name = type.name, let typeName = ExerciseTypeName(rawValue: name) else { return nil }
            originalTypes.append(typeName)
        }
        self.originalTypes = originalTypes
        super.init(management: management)
        for type in types {
            guard let name = type.name, let typeName = ExerciseTypeName(rawValue: name) else { return nil }
            super.updateTypesWith(selection: typeName)
        }
        self.exerciseName = template.name
    }
    
    override func saveExercise(withName name: String, successCompletion completion: @escaping () -> Void) {
        guard let ogName = template.name else { return }
        management.update(exerciseTemplate: template, with: name, and: exerciseTypes)
        if ogName != name {
            ExerciseDataManager().change(exerciseName: ogName, to: name)
        }
        finishSave(name: name, completion: completion)
    }
    
    override func nameConflictExists(_ newName: String) -> Bool {
        false
    }
}
