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
        if tableView == nil {
            let tblv = UITableView()
            view.addSubview(tblv)
            tableView = tblv
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        }
        tableView.register(UINib(nibName: "ExerciseSetDataCell", bundle: nil), forCellReuseIdentifier: ExerciseSetReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 75
        if readOnly {
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(done(_:)))
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
        if readOnly || viewModel.rowCount() == 0 {
            self.navigationController?.popViewController(animated: true)
        } else {
            presentExerciseCompletionConfirmation()
        }
    }
    
    func presentExerciseCompletionConfirmation() {
        let alert = UIAlertController(title: "Exercise Completed?", message: "A completed exercise cannot be edited", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { (action) in
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
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        dismiss(animated: true, completion: nil)
        
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: 60)))
        for i in 0...2 {
            let label = UILabel(frame: CGRect(x: CGFloat(i) * tableView.frame.width/3.0, y: 0, width: tableView.frame.width / 3.0, height: 40))
            label.text = headerLabelText(i)
            view.addSubview(label)
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        }
        return view
    }
    
    private func headerLabelText(_ index: Int) -> String {
        if index == 0 {
            return "Weight"
        } else if index == 1 {
            return "Reps"
        }
        return "Time"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseSetReuseIdentifier) as! ExerciseSetTableViewCell
        let data = viewModel.dataForRow(indexPath.row)
        cell.weightLabel.text = "\(data.weight)"
        cell.repsLabel.text = "\(data.reps)"
        cell.timeLabel.text = "\(data.duration)"
        return cell
    }
}

class ExerciseSetTableViewCell: UITableViewCell {
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
