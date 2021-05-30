//
//  WorkoutGraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/3/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class WorkoutGraphViewController: GraphViewController, UIPopoverPresentationControllerDelegate, ExerciseDropdownViewControllerDelegate {

    var workoutGraphViewModel: WorkoutGraphViewModel { viewModel as! WorkoutGraphViewModel }
    private var frame: CGRect?
    
    init(type: ExerciseType, frame: CGRect? = nil) {
        super.init(nibName: nil, bundle: nil)
        viewModel = WorkoutGraphViewModel(type: type)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let frame = frame {
            view.frame = frame
        }
        if isInteractive {
            setupRightBarButtonItem()
        }
    }
    
    func setupRightBarButtonItem() {
        let ellipsis = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: ellipsis, style: .plain, target: self, action: #selector(showExerciseNamesDropdown(_:)))
    }
    
    @objc func showExerciseNamesDropdown(_ sender: Any) {
        let vc = ExerciseDropdownViewController()
        vc.names = workoutGraphViewModel.getExerciseNames()
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.containerView?.backgroundColor = PPLColor.clear
        vc.popoverPresentationController?.presentedView?.backgroundColor = PPLColor.clear
        present(vc, animated: true, completion: nil)
    }
    
    func didSelectName(_ name: String) {
        dismiss(animated: true) {
            let vc = ExerciseGraphViewController(name: name)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        guard let item = navigationItem.rightBarButtonItem else {
            return
        }
        popoverPresentationController.barButtonItem = item
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
