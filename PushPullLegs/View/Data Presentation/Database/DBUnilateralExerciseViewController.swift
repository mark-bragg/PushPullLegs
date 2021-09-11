//
//  DBUnilateralExerciseViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/28/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class DBUnilateralExerciseViewController: DBExerciseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sectionCount?() ?? 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = super.tableView(tableView, viewForHeaderInSection: section) else { return nil }
        updateSectionHeaders(section, view)
        return view
    }
    
    override func addAction(_ sender: Any) {
        unilateralAddActionResponse(sender) {
            super.addAction(sender)
        }
    }
}
