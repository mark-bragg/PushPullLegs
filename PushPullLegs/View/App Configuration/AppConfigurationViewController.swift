//
//  AppConfigurationViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let defaultCellIdentifier = "DefaultTableViewCell"

class AppConfigurationViewController: PPLTableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel = AppConfigurationViewModel()
        tableView.rowHeight = tableView.frame.height / 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if indexPath.row == 2 {
            configureKilogramsPoundsSwitch(cell: cell)
        } else if indexPath.row == 3 {
            configureStartNextWorkoutPromptSwitch(cell: cell)
        } else {
            cell.selectionStyle = .default
            cell.addDisclosureIndicator()
        }
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.numberOfLines = 2
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            cell.rootView.addSubview(textLabel!)
            textLabel?.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: 20).isActive = true
            textLabel?.trailingAnchor.constraint(equalTo: nameLabelTrailingAnchor(cell.rootView), constant: 5).isActive = true
        }
        textLabel?.text = viewModel.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 4.0, rect: cell.frame)
        return cell
    }
    
    fileprivate func nameLabelTrailingAnchor(_ view: UIView) -> NSLayoutXAxisAnchor {
        if let iv = view.subviews.first(where: { $0.isKind(of: UISwitch.self) }) {
            return iv.leadingAnchor
        }
        return view.trailingAnchor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        if let segueId = segueIdentifierForRow(indexPath.row) {
            performSegue(withIdentifier: segueId, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / 4.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func segueIdentifierForRow(_ row: Int) -> String? {
        switch row {
        case 0: return SegueIdentifier.editWorkoutList
        case 1: return SegueIdentifier.editExerciseList
        default: break
        }
        return nil
    }
    
    func configureKilogramsPoundsSwitch(cell: PPLTableViewCell) {
        if let _ = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        cell.rootView.isUserInteractionEnabled = true
        let switchV = switchView(cell)
        switchV.setOn(PPLDefaults.instance.isKilograms(), animated: false)
        switchV.addTarget(self, action: #selector(toggleKilogramsPoundsValue(_:)), for: .valueChanged)
    }

    @objc func toggleKilogramsPoundsValue(_ switchView: UISwitch) {
        PPLDefaults.instance.toggleKilograms()
        self.tableView.reloadData()
    }
    
    func configureStartNextWorkoutPromptSwitch(cell: PPLTableViewCell) {
        if let _ = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        cell.rootView.isUserInteractionEnabled = true
        let switchV = switchView(cell)
        switchV.setOn(PPLDefaults.instance.workoutTypePromptSwitchValue(), animated: false)
        switchV.addTarget(self, action: #selector(toggleWorkoutTypePromptValue(_:)), for: .valueChanged)
    }

    @objc func toggleWorkoutTypePromptValue(_ switchView: UISwitch) {
        PPLDefaults.instance.toggleWorkoutTypePromptValue()
        tableView.reloadData()
    }
    
    fileprivate func switchView(_ cell: PPLTableViewCell) -> UISwitch {
        let switchView = UISwitch()
        switchView.layer.masksToBounds = true
        switchView.layer.borderWidth = 2.0
        switchView.layer.cornerRadius = 16
        switchView.layer.borderColor = PPLColor.lightGrey?.cgColor
        cell.rootView.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -20).isActive = true
        switchView.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        cell.selectionStyle = .none
        return switchView
    }
    
}

class AppConfigurationViewModel: NSObject, PPLTableViewModel {
    func rowCount(section: Int) -> Int {
        return 4
    }
    
    func title(indexPath: IndexPath) -> String? {
        switch indexPath.row {
        case 0:
            return "Edit Workout List"
        case 1:
            return "Edit Exercise List"
        case 2:
            if PPLDefaults.instance.isKilograms() {
                return "Kilograms"
            }
            return "Pounds"
        default:
            if PPLDefaults.instance.workoutTypePromptSwitchValue() {
                return "Custom Workout Choice"
            }
            return "Start Next Workout in Program"
        }
    }
    
    
}
