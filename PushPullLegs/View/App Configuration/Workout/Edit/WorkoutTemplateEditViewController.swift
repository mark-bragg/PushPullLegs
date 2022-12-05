//
//  WorkoutTemplateEditViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let exerciseCellReuseIdentifier = "ExerciseCell"
let AppConfigurationCellReuseIdentifier = "AppConfigurationCellReuseIdentifier"

class WorkoutTemplateEditViewController: PPLTableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAddButton()
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        let vc = ExerciseTemplateCreationViewController()
        if let type = workoutTemplateEditViewModel?.exerciseType, let tempMgmt = workoutTemplateEditViewModel?.templateManagement {
            let vm = ExerciseTemplateCreationViewModel(withType: type, management: tempMgmt)
            vm.reloader = self
            vc.viewModel = vm
        }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true, completion: nil)
    }
    
    private var workoutTemplateEditViewModel: WorkoutTemplateEditViewModel? {
        viewModel as? WorkoutTemplateEditViewModel
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: tableView.frame.width, height: cell.frame.height)
        cell.multiSelect = true
        cell.setSelected(workoutTemplateEditViewModel?.isSelected(indexPath) ?? false, animated: true)
        label(forCell: cell).text = workoutTemplateEditViewModel?.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var isSelected = false
        if indexPath.section == 0 {
            workoutTemplateEditViewModel?.selected(indexPath: indexPath)
        } else {
            workoutTemplateEditViewModel?.selected(indexPath: indexPath)
            isSelected = true
        }
        if let cell = tableView.cellForRow(at: indexPath) as? PPLTableViewCell {
            cell.setSelected(isSelected, animated: true)
        }
        reload()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = workoutTemplateEditViewModel?.titleForSection(section) else { return nil }
        return tableHeaderViewContainer(titles: [title])
    }
    
    override func reload() {
        workoutTemplateEditViewModel?.reload()
        super.reload()
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.workoutTemplateEditVC
    }
    
}
