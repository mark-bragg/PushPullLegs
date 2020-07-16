//
//  AddWorkoutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 3/19/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let workoutTitleCellReuseIdentifier = "WorkoutTitleCell"

class WorkoutTemplateListViewController: PPLTableViewController {
    
    var firstLoad = true
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement())
    }
    
    private func workoutTemplateListViewModel() -> WorkoutTemplateListViewModel {
        return viewModel as! WorkoutTemplateListViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        label(forCell: cell).text = viewModel.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 3.0, rect: cell.frame)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            return
        }
        workoutTemplateListViewModel().select(indexPath)
        performSegue(withIdentifier: SegueIdentifier.editWorkout, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.editWorkout, let vc = segue.destination as? WorkoutTemplateEditViewController {
            vc.viewModel = WorkoutTemplateEditViewModel(withType: workoutTemplateListViewModel().selectedType(), templateManagement: TemplateManagement())
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

extension CGRect {
    static func update(height: CGFloat , rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
    }
}

extension UIViewController {
    func label(forCell cell: PPLTableViewCell) -> PPLNameLabel {
        var label = cell.greenBackground.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if label == nil {
            label = PPLNameLabel()
            cell.greenBackground.addSubview(label!)
            label?.translatesAutoresizingMaskIntoConstraints = false
            label?.centerYAnchor.constraint(equalTo: cell.greenBackground.centerYAnchor).isActive = true
            label?.centerXAnchor.constraint(equalTo: cell.greenBackground.centerXAnchor).isActive = true
            label?.leadingAnchor.constraint(equalTo: cell.greenBackground.leadingAnchor, constant: 20).isActive = true
            label?.font = UIFont.systemFont(ofSize: 26, weight: .semibold)
            label?.textAlignment = .center
        }
        return label!
    }
}
