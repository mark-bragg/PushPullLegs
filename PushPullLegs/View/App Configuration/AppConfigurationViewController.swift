//
//  AppConfigurationViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

let defaultCellIdentifier = "DefaultTableViewCell"

class AppConfigurationViewController: PPLTableViewController, UIPopoverPresentationControllerDelegate {
    
    private var switchWidth: CGFloat = 0
    private var cancellables = [AnyCancellable]()
    private weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AppConfigurationViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        if indexPath.row < 2 {
            cell.selectionStyle = .default
            cell.addDisclosureIndicator()
        } else {
            cell.selectionStyle = .none
            if indexPath.row == 2 {
                configureKilogramsPoundsSwitch(cell: cell)
            } else if indexPath.row == 3 {
                configureStartNextWorkoutPromptSwitch(cell: cell)
            } else {
                configureCustomCountdownCell(cell: cell)
            }
        }
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil {
            textLabel = PPLNameLabel()
            textLabel?.numberOfLines = 2
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            cell.rootView.addSubview(textLabel!)
            textLabel?.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
            textLabel?.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: 20).isActive = true
            textLabel?.trailingAnchor.constraint(equalTo: nameLabelTrailingAnchor(cell.rootView), constant: 5).isActive = true
        }
        textLabel?.text = viewModel.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 4.0, rect: cell.frame)
        return cell
    }
    
    fileprivate func nameLabelTrailingAnchor(_ view: UIView) -> NSLayoutXAxisAnchor {
        if let iv = view.subviews.first(where: { $0.isKind(of: UISwitch.self) }) {
            return iv.leadingAnchor
        }
        return view.trailingAnchor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueId = segueIdentifierForRow(indexPath.row) {
            performSegue(withIdentifier: segueId, sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func segueIdentifierForRow(_ row: Int) -> String? {
        switch row {
        case 0: return SegueIdentifier.editWorkoutList
        case 1: return SegueIdentifier.editExerciseList
        default: break
        }
        return nil
    }
    
    func configureKilogramsPoundsSwitch(cell: PPLTableViewCell) {
        if let _ = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        cell.rootView.isUserInteractionEnabled = true
        let switchV = switchView(cell)
        switchV.setOn(PPLDefaults.instance.isKilograms(), animated: false)
        switchV.addTarget(self, action: #selector(toggleKilogramsPoundsValue(_:)), for: .valueChanged)
        switchWidth = switchV.frame.width
    }

    @objc func toggleKilogramsPoundsValue(_ switchView: UISwitch) {
        PPLDefaults.instance.toggleKilograms()
        self.tableView.reloadData()
    }
    
    func configureStartNextWorkoutPromptSwitch(cell: PPLTableViewCell) {
        if let _ = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        cell.rootView.isUserInteractionEnabled = true
        let switchV = switchView(cell)
        switchV.setOn(PPLDefaults.instance.workoutTypePromptSwitchValue(), animated: false)
        switchV.addTarget(self, action: #selector(toggleWorkoutTypePromptValue(_:)), for: .valueChanged)
    }

    @objc func toggleWorkoutTypePromptValue(_ switchView: UISwitch) {
        PPLDefaults.instance.toggleWorkoutTypePromptValue()
        tableView.reloadData()
    }
    
    func configureCustomCountdownCell(cell: PPLTableViewCell) {
        if let _ = cell.rootView.viewWithTag(2929) { return }
        cell.rootView.isUserInteractionEnabled = true
        let countdownLabel = UILabel()
        countdownLabel.tag = 2929
        countdownLabel.textAlignment = .center
        countdownLabel.font = UIFont.systemFont(ofSize: 36)
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.text = "\(PPLDefaults.instance.countdown())"
        countdownLabel.sizeToFit()
        cell.rootView.addSubview(countdownLabel)
        countdownLabel.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -20).isActive = true
        countdownLabel.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        countdownLabel.widthAnchor.constraint(equalToConstant: switchWidth).isActive = true
        countdownLabel.heightAnchor.constraint(equalToConstant: countdownLabel.frame.height).isActive = true
        countdownLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCountdownPicker(_:))))
        countdownLabel.isUserInteractionEnabled = true
        self.countdownLabel = countdownLabel
    }
    
    @objc func showCountdownPicker(_ tappy: UITapGestureRecognizer) {
        let picker = CountdownPickerViewController()
        picker.modalPresentationStyle = .popover
        picker.view.backgroundColor = .black
        picker.preferredContentSize = CGSize(width: 200, height: 200)
        picker.popoverPresentationController?.sourceView = tappy.view
        picker.popoverPresentationController?.sourceRect = CGRect(x: 0, y: tappy.view!.frame.height/2, width: 0, height: 0)
        picker.popoverPresentationController?.delegate = self
        present(picker, animated: true, completion: {
            picker.$countdownSelection.sink { [weak self] (value) in
                guard let seconds = value, let self = self else { return }
                PPLDefaults.instance.setCountdown(seconds)
                self.countdownLabel.text = "\(seconds)"
            }
            .store(in: &self.cancellables)
        })
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .right
        popoverPresentationController.sourceView = countdownLabel
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    fileprivate func switchView(_ cell: PPLTableViewCell) -> UISwitch {
        let switchView = UISwitch()
        switchView.layer.masksToBounds = true
        switchView.layer.borderWidth = 2.0
        switchView.layer.cornerRadius = 16
        switchView.layer.borderColor = PPLColor.lightGrey?.cgColor
        cell.rootView.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -20).isActive = true
        switchView.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        return switchView
    }
    
}

class AppConfigurationViewModel: NSObject, PPLTableViewModel {
    func rowCount(section: Int) -> Int {
        return 5
    }
    
    func title(indexPath: IndexPath) -> String? {
        switch indexPath.row {
        case 0:
            return "Edit Workout List"
        case 1:
            return "Edit Exercise List"
        case 2:
            if PPLDefaults.instance.isKilograms() {
                return "Kilograms"
            }
            return "Pounds"
        case 3:
            if PPLDefaults.instance.workoutTypePromptSwitchValue() {
                return "Custom Workout Choice"
            }
            return "Start Next Workout in Program"
        case 4:
            return "Countdown for each set"
        default:
            return "ERROR"
        }
        
    }
}

class CountdownPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var picker: UIPickerView!
    @Published private(set) var countdownSelection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(picker)
        picker.delegate = self
        picker.backgroundColor = PPLColor.darkGrey
        picker.tintColor = .black
        picker.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        self.picker = picker
        picker.selectRow(PPLDefaults.instance.countdown(), inComponent: 0, animated: false)
    }
    
    // MARK: DATA SOURCE
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        31
    }
    
    // MARK: DELEGATE
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        25
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdownSelection = row
    }
}
