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

class ExerciseViewController: PPLTableViewController, ExerciseSetViewModelDelegate, ExercisingViewController, UIAdaptivePresentationControllerDelegate, ReloadProtocol {

    weak var weightCollector: WeightCollectionViewController!
    weak var exerciseTimer: ExerciseTimerViewController!
    weak var repsCollector: RepsCollectionViewController!
    var exerciseSetViewModel: ExerciseSetViewModel?
    var readOnly = false
    weak var restTimerView: RestTimerView!
    private let timerHeight: CGFloat = 75.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !readOnly && addButton == nil {
            setupAddButton()
        }
        navigationItem.title = exerciseViewModel().title()
        tableView.allowsSelection = false
    }
    
    override func pop() {
        if readOnly || exerciseViewModel().rowCount(section: 0) == 0 {
            super.pop()
            AppState.shared.exerciseInProgress = nil
        } else {
            presentExerciseCompletionConfirmation()
        }
    }
    
    func exerciseViewModel() -> ExerciseViewModel {
        return viewModel as! ExerciseViewModel
    }
    
    override func addAction(_ sender: Any) {
        super.addAction(sender)
        exerciseSetViewModel = ExerciseSetViewModel()
        exerciseSetViewModel?.delegate = self
        exerciseSetViewModel?.setCollector = exerciseViewModel()
        let wc = WeightCollectionViewController()
        wc.exerciseSetViewModel = exerciseSetViewModel
        presentModally(wc)
        weightCollector = wc
        if let v = restTimerView {
            v.removeFromSuperview()
        }
    }
    
    @IBAction func addSet(_ sender: Any) {
        
    }
    
    @IBAction func done(_ sender: Any) {
        
    }
    
    func presentExerciseCompletionConfirmation() {
        let alert = UIAlertController(title: "Exercise Completed?", message: "A completed exercise cannot be edited", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
            AppState.shared.exerciseInProgress = nil
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
        dismiss(animated: true, completion: { self.reload() })
        setupRestTimerView()
        if exerciseViewModel().rowCount() > 0 {
            AppState.shared.exerciseInProgress = !readOnly ? exerciseViewModel().title() : nil
        }
    }
    
    func exerciseSetViewModelCanceledSet(_ viewModel: ExerciseSetViewModel) {
        dismiss(animated: true, completion: nil)
        resetState()
    }
    
    func setupRestTimerView() {
        if (AppState.shared.isAdEnabled) {
            positionBannerView(yOffset: timerHeight)
        }
        let timerView = RestTimerView(frame: CGRect(x: 0, y: view.frame.height - timerHeight, width: view.frame.width, height: timerHeight))
        view.addSubview(timerView)
        restTimerView = timerView
        restTimerView.restartTimer()
    }
    
    func presentModally(_ vc: UIViewController) {
        vc.modalPresentationStyle = .formSheet
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var titles = [String]()
        for i in 0...2 {
            titles.append(exerciseViewModel().headerLabelText(i))
        }
        let view = tableHeaderView(titles: titles)
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        let data = exerciseViewModel().dataForRow(indexPath.row)
        let contentFrame = cell.frame
        let weightLabel = PPLNameLabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width / 3, height: contentFrame.height))
        let repsLabel = PPLNameLabel(frame: CGRect(x: weightLabel.frame.width, y: 0, width: tableView.frame.width / 3, height: contentFrame.height))
        let timeLabel = PPLNameLabel(frame: CGRect(x: weightLabel.frame.width * 2, y: 0, width: tableView.frame.width / 3, height: contentFrame.height))
        weightLabel.text = "\(data.weight)"
        repsLabel.text = "\(data.reps)"
        timeLabel.text = "\(data.duration)"
        for lbl in [weightLabel, repsLabel, timeLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textAlignment = .center
            cell.contentView.addSubview(lbl)
        }
        return cell
    }
    
}

class RestTimerView: UIView {
    private var text: String? {
        willSet {
            timerLabel.text = newValue
        }
    }
    private var timerLabel = UILabel()
    private var stopWatch: PPLStopWatch!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func restartTimer() {
        weak var weakSelf = self
        stopWatch = PPLStopWatch(withHandler: { (seconds) in
            DispatchQueue.main.async {
                guard let strongSelf = weakSelf else { return }
                strongSelf.text = String.format(seconds: seconds)
            }
        })
        stopWatch.start()
    }
    
    override func layoutSubviews() {
        if !subviews.contains(timerLabel) {
            setupTimerLabel()
        }
        backgroundColor = .systemRed
    }
    
    func setupTimerLabel() {
        timerLabel.frame = CGRect(x: 20, y: 10, width: frame.width - 40, height: frame.height - 20)
        timerLabel.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
        timerLabel.textColor = .white
        addSubview(timerLabel)
        timerLabel.textAlignment = .center
        timerLabel.backgroundColor = .clear
    }
}

extension UILabel {
    static func headerLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
        return label
    }
}

class ExerciseSetTableViewCell: UITableViewCell {
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
