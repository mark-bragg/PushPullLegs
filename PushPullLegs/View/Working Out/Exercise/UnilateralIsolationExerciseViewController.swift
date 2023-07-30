//
//  UnilateralIsolationExerciseViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/23/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

class UnilateralIsolationExerciseViewController: ExerciseViewController {
    
    private var isPresentingPrevious = false
    private var uniIsoVM: UnilateralIsolationExerciseViewModel? { viewModel as? UnilateralIsolationExerciseViewModel }
    
    override func addAction() {
        unilateralIsolationAddActionResponse {
            super.addAction()
        }
    }
    
    override func weightCollectionViewController() -> WeightCollectionViewController {
        WeightCollectionViewController()
    }
    
    override func presentPreviousPerformance() {
        isPresentingPrevious = true
        guard
            let uniIsoVM,
            let previousExercise = (viewModel as? ExerciseViewModel)?.previousExercise
        else { return }
        let leftSuperHeaderView = tableHeaderViewContainer(titles: [uniIsoVM.titleForSection(0) ?? ""], section: 0)
        let rightSuperHeaderView = tableHeaderViewContainer(titles: [uniIsoVM.titleForSection(1) ?? ""], section: 1)
//        let leftHeaderView = updateSectionHeaders(0, leftSuperHeaderView)
//        let rightHeaderView = updateSectionHeaders(1, rightSuperHeaderView)
        presentModally(PreviousUnilateralIsolationPerformanceViewController(exercise: previousExercise, headerViews: [leftSuperHeaderView, rightSuperHeaderView]))
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let vm = uniIsoVM,
              vm.rowCount(section: section) > 0 || isPresentingPrevious
        else { return nil }
//        return updateSectionHeaders(section, superHeader)
        return tableHeaderViewContainer(titles: [vm.titleForSection(section) ?? ""], section: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let uniIsoVM else { return 0 }
        if section == 0 && uniIsoVM.rowCount(section: 0) > 0 {
            return 40
        } else if section == 1 && uniIsoVM.rowCount(section: 1) > 0 {
            return 40
        } else if isPresentingPrevious {
            return 40
        }
        return 0
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        isPresentingPrevious = false
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
    
    func unilateralIsolationAddActionResponse(completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Which side are you lifting?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(alertAction(.left, completion: completion))
        alert.addAction(alertAction(.right, completion: completion))
        present(alert, animated: true, completion: nil)
    }
    
    private func alertAction(_ side: HandSide, completion: @escaping () -> Void) -> UIAlertAction {
        let vm = unilateralIsolationVM
        return UIAlertAction(title: side.rawValue, style: .default) { _ in
            vm?.currentSide = side
            completion()
        }
    }
    
    private var unilateralIsolationVM: UnilateralIsolationExerciseViewModel? {
        self.viewModel as? UnilateralIsolationExerciseViewModel
    }
}
