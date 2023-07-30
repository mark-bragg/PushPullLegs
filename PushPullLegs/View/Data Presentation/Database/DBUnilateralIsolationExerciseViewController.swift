//
//  DBUnilateralIsolationExerciseViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/28/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class DBUnilateralIsolationExerciseViewController: DBExerciseViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sectionCount?() ?? 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let vm = viewModel, vm.rowCount(section: section) > 0 else { return nil }
        return tableHeaderViewContainer(titles: [section == 0 ? "Left" : "Right"], section: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let vm = viewModel else { return 0 }
        return vm.rowCount(section: section) > 0 ? 40 : 0
    }
    
    override func addAction() {
        unilateralIsolationAddActionResponse {
            super.addAction()
        }
    }
    
    override func weightCollectionViewController() -> WeightCollectionViewController {
        WeightCollectionViewController()
    }
}
