//
//  AddWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class WorkoutTemplateListViewController: PPLTableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement())
        super.viewWillAppear(animated)
    }
    
    private var workoutTemplateListViewModel: WorkoutTemplateListViewModel? {
        viewModel as? WorkoutTemplateListViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier),
              let rowCount = viewModel?.rowCount(section: 0),
              rowCount > 0
        else { return UITableViewCell() }
        label(forCell: cell, fontSize: 64)?.text = viewModel?.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / CGFloat(rowCount), rect: cell.frame)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else { return }
        workoutTemplateListViewModel?.select(indexPath)
        guard let selectedType = workoutTemplateListViewModel?.selectedType else { return }
        let vc = WorkoutTemplateEditViewController()
        vc.viewModel = WorkoutTemplateEditViewModel(withType: selectedType, templateManagement: TemplateManagement())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let workoutTemplateListViewModel else { return 0 }
        return tableView.frame.height / CGFloat(workoutTemplateListViewModel.rowCount(section: 0))
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
}

extension CGRect {
    static func update(height: CGFloat , rect: CGRect) -> CGRect {
        CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
    }
}

extension UIViewController {
    func label(forCell cell: UITableViewCell, fontSize: CGFloat = 26) -> PPLNameLabel? {
        if let label = cell.contentView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel {
            return label
        }
        let label = PPLNameLabel()
        cell.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20)
        ])
        label.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        label.textAlignment = .center
        label.textColor = PPLColor.text
        return label
    }
}
