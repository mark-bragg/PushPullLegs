//
//  SuperSetViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

class SuperSetViewController: ExerciseTemplateSelectionViewController {
    weak var superSetDelegate: SuperSetDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.allowsMultipleSelection = false
    }
    
    override func setupBarButtonItems() {
        // no op
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let name = exerciseSelectionViewModel?.title(indexPath: indexPath)
        else { return }
        superSetDelegate?.secondExerciseSelected(name)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        super.tableHeaderViewContainer(titles: ["Select Exercise For Second Set"])
    }
}
