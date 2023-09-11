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
    var exerciseSelectionViewModel: ExerciseSelectionViewModel? { viewModel as? ExerciseSelectionViewModel }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.register(PPLSelectionCell.self, forCellReuseIdentifier: UITableViewCellIdentifier)
        tableView?.allowsMultipleSelection = true
        navigationItem.title = exerciseSelectionViewModel?.title()
        setupBarButtonItems()
    }
    
    func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pop))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExercise))
    }
    
    @objc override func pop() {
        super.pop()
        guard let exerciseSelectionViewModel, exerciseSelectionViewModel.selectedExercises().count > 0 else { return }
        exerciseSelectionViewModel.commitChanges()
        delegate?.exerciseTemplatesAdded()
    }
    
    override func addNoDataView() {
        // no op
    }
    
    @objc func addExercise() {
        guard let exerciseSelectionViewModel else { return }
        let vc = ExerciseTemplateCreationViewController()
        vc.showExerciseType = false
        vc.viewModel = ExerciseTemplateCreationViewModel(withType: exerciseSelectionViewModel.exerciseType, management: TemplateManagement())
        vc.viewModel?.reloader = self
        vc.modalPresentationStyle = .pageSheet
        vc.presentationController?.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier) as? PPLSelectionCell else {
            return UITableViewCell()
        }
        var textLabel = cell.contentView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = newTextLabel(cell.contentView)
        }
        textLabel?.text = exerciseSelectionViewModel?.title(indexPath: indexPath)
        return cell
    }
    
    private func newTextLabel(_ rootView: UIView) -> PPLNameLabel {
        let textLabel = PPLNameLabel()
        textLabel.textColor = PPLColor.text
        textLabel.textAlignment = .left
        rootView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: 10).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 10).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: rootView.centerYAnchor, constant: 0).isActive = true
        return textLabel
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exerciseSelectionViewModel?.selected(row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        exerciseSelectionViewModel?.deselected(row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableHeaderViewContainer(titles: ["Select Exercises To Add"])
    }
    
    override func reload() {
        exerciseSelectionViewModel?.reload()
        tableView?.reloadData()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension ExerciseTemplateSelectionViewController {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        
    }
}

class PPLSelectionCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override var selectionStyle: UITableViewCell.SelectionStyle {
        get { .none }
        set { super.selectionStyle = .none }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}
