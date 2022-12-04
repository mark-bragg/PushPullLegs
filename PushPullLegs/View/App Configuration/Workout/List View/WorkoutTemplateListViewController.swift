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
        viewModel = WorkoutTemplateListViewModel(withTemplateManagement: TemplateManagement())
        super.viewWillAppear(animated)
    }
    
    private func workoutTemplateListViewModel() -> WorkoutTemplateListViewModel {
        return viewModel as! WorkoutTemplateListViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        label(forCell: cell, fontSize: 64).text = viewModel?.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 3.0, rect: cell.frame)
        cell.addDisclosureIndicator()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.isEditing else {
            return
        }
        workoutTemplateListViewModel().select(indexPath)
        let vc = WorkoutTemplateEditViewController()
        vc.viewModel = WorkoutTemplateEditViewModel(withType: workoutTemplateListViewModel().selectedType(), templateManagement: TemplateManagement())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 3.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.workoutTemplateListVC
    }
}

extension CGRect {
    static func update(height: CGFloat , rect: CGRect) -> CGRect {
        return CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: height)
    }
}

extension UIViewController {
    func label(forCell cell: PPLTableViewCell, fontSize: CGFloat = 26) -> PPLNameLabel {
        guard let rootView = cell.rootView else { return PPLNameLabel() }
        var label = rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if label == nil {
            label = PPLNameLabel()
            rootView.addSubview(label!)
            label?.translatesAutoresizingMaskIntoConstraints = false
            label?.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
            label?.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
            label?.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
            label?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
            label?.textAlignment = .center
            label?.textColor = PPLColor.text
        }
        return label!
    }
}
