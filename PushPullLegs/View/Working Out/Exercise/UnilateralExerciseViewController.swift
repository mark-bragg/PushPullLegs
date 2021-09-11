//
//  UnilateralExerciseViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class UnilateralExerciseViewController: ExerciseViewController {
    
    override func addAction(_ sender: Any) {
        unilateralAddActionResponse(sender) {
            super.addAction(sender)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let superHeader = super.tableView(tableView, viewForHeaderInSection: section) else { return nil }
        return updateSectionHeaders(section, superHeader)
    }

}

extension ExerciseViewController {
    func updateSectionHeaders(_ section: Int, _ superHeader: UIView) -> UIView {
        let sectLbl = UILabel()
        sectLbl.text = headerTitle(section)
        sectLbl.sizeToFit()
        superHeader.addSubview(sectLbl)
        return superHeader
    }
    
    private func headerTitle(_ section: Int) -> String {
        section == 0 ? HandSide.left.rawValue : HandSide.right.rawValue
    }
    
    func unilateralAddActionResponse(_ sender: Any, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Which side are you lifting?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(alertAction(.left, completion: completion))
        alert.addAction(alertAction(.right, completion: completion))
        present(alert, animated: true, completion: nil)
    }
    
    private func alertAction(_ side: HandSide, completion: @escaping () -> Void) -> UIAlertAction {
        let vm = unilateralVM
        return UIAlertAction(title: side.rawValue, style: .default) { _ in
            vm?.currentSide = side
            completion()
        }
    }
    
    private var unilateralVM: UnilateralExerciseViewModel? {
        self.viewModel as? UnilateralExerciseViewModel
    }
}
