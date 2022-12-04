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
    
    private weak var countdownLabel: UILabel!
    private var interstitial: NSObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AppConfigurationViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.isUserInteractionEnabled = true
    }
    
    override func viewWillLayoutSubviews() {
        viewModel = AppConfigurationViewModel()
        super.viewWillLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.rowCount(section: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        guard let rootView = cell.rootView else { return cell }
        rootView.subviews.forEach { $0.removeFromSuperview() }
        rootView.gestureRecognizers?.forEach { rootView.removeGestureRecognizer($0) }
        cell.selectionStyle = .default
        if indexPath.row < 3 {
            cell.addDisclosureIndicator()
        } else if indexPath.row < 7 {
            cell.selectionStyle = .none
            if indexPath.row == 3 {
                configureImperialMetricSegmenedControl(cell: cell)
            } else if indexPath.row == 4 {
                configureCustomCountdownCell(cell: cell)
            } else if indexPath.row == 5 {
                configureTimerSoundsCell(cell: cell)
            }
        } else {
            
        }
        
        var textLabel = rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil && indexPath.row != 3 {
            textLabel = textLabelForCell(cell)
        }
        textLabel?.textColor = PPLColor.text
        textLabel?.text = viewModel?.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 4.0, rect: cell.frame)
        return cell
    }
    
    func configureImperialMetricSegmenedControl(cell: PPLTableViewCell) {
        guard let rootView = cell.rootView else { return }
        if let _ = rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        rootView.isUserInteractionEnabled = true
        let segment = UISegmentedControl.PPLSegmentedControl(titles: ["Imperial", "Metric"], target: self, selector: #selector(toggleKilogramsPoundsValue(_:)))
        segment.selectedSegmentIndex = PPLDefaults.instance.isKilograms() ? 1 : 0
        rootView.addSubview(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        segment.centerXAnchor.constraint(equalTo: rootView.centerXAnchor).isActive = true
        segment.widthAnchor.constraint(equalTo: rootView.widthAnchor, multiplier: 0.9).isActive = true
        segment.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.75).isActive = true
    }

    @objc func toggleKilogramsPoundsValue(_ control: UISegmentedControl) {
        let measurementType = control.selectedSegmentIndex == 0 ? MeasurementType.imperial : MeasurementType.metric
        PPLDefaults.instance.setImperialMetric(measurementType)
        tableView?.reloadData()
    }
    
    func configureCustomCountdownCell(cell: PPLTableViewCell) {
        guard let rootView = cell.rootView else { return }
        if let _ = rootView.viewWithTag(2929) { return }
        rootView.isUserInteractionEnabled = true
        let countdownLabel = labelForCountdown()
        rootView.addSubview(countdownLabel)
        countdownLabel.tag = 2929
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -18).isActive = true
        countdownLabel.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        countdownLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
        countdownLabel.heightAnchor.constraint(equalToConstant: countdownLabel.frame.height).isActive = true
        rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCountdownPicker)))
        self.countdownLabel = countdownLabel
    }
    
    @objc func showCountdownPicker() {
        let picker = CountdownPickerViewController()
        picker.modalPresentationStyle = .popover
        picker.preferredContentSize = CGSize(width: countdownLabel.frame.width, height: 250)
        picker.popoverPresentationController?.sourceView = countdownLabel
        picker.popoverPresentationController?.sourceRect = CGRect(x: countdownLabel.frame.width/2, y: 6, width: 0, height: countdownLabel.frame.height)
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
    
    func configureTimerSoundsCell(cell: PPLTableViewCell) {
        cell.rootView?.isUserInteractionEnabled = true
        let cellSwitch = switchView(cell)
        cellSwitch.isOn = PPLDefaults.instance.areTimerSoundsEnabled()
        cellSwitch.addTarget(self, action: #selector(setTimerSoundsEnabled(_:)), for: .valueChanged)
    }
    
    @objc func setTimerSoundsEnabled(_ sender: UISwitch) {
        PPLDefaults.instance.setTimerSoundsEnabled(sender.isOn)
    }
    
    fileprivate func textLabelForCell(_ cell: PPLTableViewCell) -> PPLNameLabel {
        let lbl = PPLNameLabel()
        lbl.numberOfLines = 2
        cell.rootView?.addSubview(lbl)
        constrain(lbl, cell)
        return lbl
    }
    
    fileprivate func constrain(_ lbl: PPLNameLabel, _ cell: PPLTableViewCell) {
        guard let rootView = cell.rootView else { return }
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        lbl.leadingAnchor.constraint(equalTo: rootView.leadingAnchor, constant: 20).isActive = true
        lbl.trailingAnchor.constraint(equalTo: nameLabelTrailingAnchor(rootView), constant: 5).isActive = true
    }
    
    fileprivate func nameLabelTrailingAnchor(_ view: UIView) -> NSLayoutXAxisAnchor {
        if let iv = view.subviews.first(where: { $0.isKind(of: UISwitch.self) }) {
            return iv.leadingAnchor
        }
        return view.trailingAnchor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowId = appConfigurationViewModel().idForRow(indexPath.row) else { return }
        
        if rowId == .about {
            navigateToAbout()
        } else if rowId == .editWorkouts {
            let vc = WorkoutTemplateListViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else if rowId == .editExercises {
            let vc = ExerciseTemplateListViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else if rowId == .timerSounds {
            return
        } else if rowId == .disableAds {
            showSpinner(indexPath)
            let alert = UIAlertController(title: "In-app Purchase Required", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.removeSpinner()
            }))
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { action in
                StoreManager.shared.startDisableAdsTransaction()
            }))
            self.present(alert, animated: true, completion: nil)
        } else if rowId == .restorePurchases {
            showSpinner(indexPath)
            StoreManager.shared.restoreDisabledAds({ [weak self] in
                guard let self = self else { return }
                self.removeSpinner()
            }, failure: { [weak self] in
                guard let self = self else { return }
                self.removeSpinner()
            })
        }
    }
    
    func showSpinner(_ indexPath: IndexPath) {
        guard let cell = tableView?.cellForRow(at: indexPath) as? PPLTableViewCell, let rootView = cell.rootView else { return }
        let spinner = UIActivityIndicatorView(frame: rootView.frame)
        spinner.layer.cornerRadius = rootView.layer.cornerRadius
        spinner.style = .large
        spinner.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        cell.contentView.addSubview(spinner)
        spinner.startAnimating()
        spinner.tag = spinnerTag
    }
    
    private func removeSpinner() {
        guard let spinner = view.viewWithTag(spinnerTag) else { return }
        spinner.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
    
    private func navigateToAbout() {
        let vc = HowToUseAppViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
        view.isUserInteractionEnabled = true
        interstitial = nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = []
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    fileprivate func switchView(_ cell: PPLTableViewCell) -> UISwitch {
        let switchView = UISwitch()
        guard let rootView = cell.rootView else { return switchView }
        switchView.preferredStyle = .checkbox
        switchView.layer.masksToBounds = true
        switchView.layer.borderWidth = 2.0
        switchView.layer.cornerRadius = 16
        switchView.layer.borderColor = PPLColor.darkGray.cgColor
        switchView.tintColor = PPLColor.black
        switchView.backgroundColor = .gray
        rootView.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true
        switchView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        return switchView
    }
    
    override func bannerAdUnitID() -> String {
        BannerAdUnitID.appConfigurationVC
    }
    
    func appConfigurationViewModel() -> AppConfigurationViewModel {
        return viewModel as! AppConfigurationViewModel
    }
    
}

class AppConfigurationRowView: UIView {
    var mainTitle: String?
}

extension UISegmentedControl {
    static func PPLSegmentedControl(titles: [String], target: Any, selector: Selector) -> UISegmentedControl {
        let segment = UISegmentedControl()
        for i in 0..<titles.count {
            segment.insertSegment(withTitle: titles[i], at: i, animated: false)
        }
        segment.addTarget(target, action: selector, for: .valueChanged)
        segment.selectedSegmentTintColor = PPLColor.primary
        segment.backgroundColor = .pplGray
        return segment
    }
}
