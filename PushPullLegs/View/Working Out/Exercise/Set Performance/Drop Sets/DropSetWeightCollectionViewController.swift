//
//  DropSetWeightCollectionViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/22/23.
//  Copyright © 2023 Mark Bragg. All rights reserved.
//

import Combine

protocol DropSetDelegate: NSObjectProtocol {
    func dropSetSelected()
    var dropSetCount: Int { get set }
    func dropSetsStarted(with weights: [Double])
    func startNextDropSet()
    func collectDropSet(duration: Int)
    func dropSetCompleted(with reps: Double)
}

class DropSetWeightCollectionViewController: WeightCollectionViewController {
    var dropSetCount: Int = 0
    private weak var tableView: UITableView?
    private weak var tableViewHeight: NSLayoutConstraint?
    private var cancellables = Set<AnyCancellable>()
    private var cells = [UITableViewCell]()
    private var textFields: [UITextField] {
        cells.compactMap { cell in
            cell.contentView.subviews.first?.subviews.first as? UITextField
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField = nil
        addTableView()
        constrainTableView()
        NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                guard let self,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                else { return }
                self.tableViewHeight?.constant = self.view.frame.height - keyboardFrame.height
            }
            .store(in: &cancellables)
    }
    
    func addTableView() {
        let tbv = UITableView()
        tbv.dataSource = self
        tbv.rowHeight = textFieldContainerFrame().height
        view.addSubview(tbv)
        self.tableView = tbv
    }
    
    func constrainTableView() {
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableViewHeight = tableView?.heightAnchor.constraint(equalToConstant: view.frame.height)
        tableViewHeight?.isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        textFields.first?.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        textFields.first?.becomeFirstResponder()
//        tableViewHeight?.constant =
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        textFields = []
        cells = []
    }
    
    override func addSuperSetBarButtonItem() {
        // no op
    }
    
    override func addDropSetBarButtonItem() {
        // no op
    }
    
    override func addStackView() {
        // no op
        return
    }
    
    override func buttonIsEnabledAfterTextIsCorrected() -> Bool {
        for tf in textFields {
            guard let text = tf.text, text != ""
            else { return false }
        }
        return true
    }
    
    override func buttonReleased(_ sender: Any) {
        let weightTexts = textFields.compactMap({ $0.text })
        guard weightTexts.count == textFields.count else { return }
        var weights = [Double]()
        for weightText in weightTexts {
            guard let weight = Double(weightText) else { return }
            weights.append(weight)
        }
        super.buttonReleased(sender)
        dropSetDelegate?.dropSetsStarted(with: weights)
    }
}

extension DropSetWeightCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dropSetCount + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < cells.count {
            return cells[indexPath.row]
        }
        let cell = UITableViewCell()
        cell.frame = textFieldContainerFrame()
        cell.selectionStyle = .none
        if indexPath.row < dropSetCount {
            let tfc = getTextField()
            tfc.isUserInteractionEnabled = true
            guard let tf = tfc.subviews.first as? UITextField
            else { return cell }
            tf.isUserInteractionEnabled = true
            tf.keyboardType = .asciiCapableNumberPad
            tf.placeholder = "Weight for Set \(indexPath.row + 1)"
            tf.adjustsFontSizeToFitWidth = true
            cell.contentView.addSubview(tfc)
            if indexPath.row == 0 {
                tf.becomeFirstResponder()
            }
        } else {
            let btn = button ?? getButton()
            cell.contentView.addSubview(btn)
            constrain(btn, toInsideOf: cell.contentView)
            button?.setTitle("Next", for: .normal)
            button?.isEnabled = false
        }
        cells.append(cell)
        return cell
    }
}
