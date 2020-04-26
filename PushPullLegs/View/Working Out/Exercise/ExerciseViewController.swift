//
//  ExercisingViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/18/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let ExerciseSetReuseIdentifier = "ExerciseSetReuseIdentifier"

protocol ExercisingViewController: UIViewController {
    var exerciseSetViewModel: ExerciseSetViewModel? { get set }
}

class ExerciseViewController: UIViewController, ExerciseSetViewModelDelegate, ExercisingViewController, UIAdaptivePresentationControllerDelegate, ReloadProtocol {

    @IBOutlet weak var tableView: UITableView!
    weak var weightCollector: WeightCollectionViewController!
    weak var exerciseTimer: ExerciseTimerViewController!
    weak var repsCollector: RepsCollectionViewController!
    var exerciseSetViewModel: ExerciseSetViewModel?
    var viewModel: ExerciseViewModel!
    var readOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ExerciseSetReuseIdentifier)
        if readOnly {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func addSet(_ sender: Any) {
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = viewModel
        let wc = WeightCollectionViewController()
        wc.exerciseSetViewModel = exerciseSetViewModel
        presentModally(wc)
        weightCollector = wc
    }
    
    @IBAction func done(_ sender: Any) {
        if readOnly {
            self.navigationController?.popViewController(animated: true)
        } else {
            presentExerciseCompletionConfirmation()
        }
    }
    
    func presentExerciseCompletionConfirmation() {
        let alert = UIAlertController(title: "Exercise Completed?", message: "A completed exercise cannot be edited", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.exerciseCompleted()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func exerciseSetViewModelStartedSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true) {
            let et = ExerciseTimerViewController()
            et.exerciseSetViewModel = self.exerciseSetViewModel
            et.exerciseSetViewModel?.timerDelegate = et
            self.presentModally(et)
            self.exerciseTimer = et
        }
    }
    
    func exerciseSetViewModelStoppedTimer(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true) {
            let rc = RepsCollectionViewController()
            rc.exerciseSetViewModel = self.exerciseSetViewModel
            self.presentModally(rc)
            self.repsCollector = rc
        }
    }
    
    func exerciseSetViewModelFinishedSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: {
            
        })
        
    }
    
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: nil)
        resetState()
    }
    
    func presentModally(_ vc: UIViewController) {
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
        vc.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if let _ = presentationController.presentedViewController as? ExercisingViewController {
            if exerciseSetViewModel!.completedExerciseSet {
                
            } else {
                exerciseSetViewModel?.cancel()
            }
        }
        reload()
    }
    
    func resetState() {
        exerciseSetViewModel = nil
    }
    
    func reload() {
        tableView.reloadData()
    }

}

extension ExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: ExerciseSetReuseIdentifier)
        }
        var data = viewModel.dataForRow(indexPath.row)
        cell?.textLabel?.text = "\(data.reps) \(data.weight) \(data.duration) \(data.volume)"
        return cell!
    }
}