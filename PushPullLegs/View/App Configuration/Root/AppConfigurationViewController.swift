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
    private weak var defaultColorView: UIView!
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
        removeSwitch(cell)
        removeSegmentedControl(cell)
        removeDefaultColorView(cell)
        cell.removeIndicator()
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
            } else if indexPath.row == 6 {
                configureDefaultColorCell(cell: cell)
            }
        } else {
            
        }
        
        var textLabel = cell.rootView.subviews.first(where: { $0.isKind(of: PPLNameLabel.self) }) as? PPLNameLabel
        if textLabel == nil && indexPath.row != 3 {
            textLabel = textLabelForCell(cell)
        }
        textLabel?.textColor = PPLColor.text
        textLabel?.text = viewModel?.title(indexPath: indexPath)
        cell.frame = CGRect.update(height: tableView.frame.height / 4.0, rect: cell.frame)
        return cell
    }
    
    fileprivate func removeSwitch(_ cell: PPLTableViewCell) {
        guard let switcheroo = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) else { return }
        for c in switcheroo.constraints {
            c.isActive = false
        }
        switcheroo.removeFromSuperview()
    }
    
    fileprivate func removeSegmentedControl(_ cell: PPLTableViewCell) {
        guard let segmenteroo = cell.rootView.subviews.first(where: { $0.isKind(of: UISegmentedControl.self) }) else { return }
        for c in segmenteroo.constraints {
            c.isActive = false
        }
        segmenteroo.removeFromSuperview()
    }
    
    func configureImperialMetricSegmenedControl(cell: PPLTableViewCell) {
        if let _ = cell.rootView.subviews.first(where: { $0.isKind(of: UISwitch.self) }) as? UISwitch { return }
        cell.rootView.isUserInteractionEnabled = true
        let segment = UISegmentedControl.PPLSegmentedControl(titles: ["Imperial", "Metric"], target: self, selector: #selector(toggleKilogramsPoundsValue(_:)))
        segment.selectedSegmentIndex = PPLDefaults.instance.isKilograms() ? 1 : 0
        cell.rootView.addSubview(segment)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        segment.centerXAnchor.constraint(equalTo: cell.rootView.centerXAnchor).isActive = true
        segment.widthAnchor.constraint(equalTo: cell.rootView.widthAnchor, multiplier: 0.9).isActive = true
        segment.heightAnchor.constraint(equalTo: cell.rootView.heightAnchor, multiplier: 0.75).isActive = true
    }

    @objc func toggleKilogramsPoundsValue(_ control: UISegmentedControl) {
        let measurementType = control.selectedSegmentIndex == 0 ? MeasurementType.imperial : MeasurementType.metric
        PPLDefaults.instance.setImperialMetric(measurementType)
        tableView?.reloadData()
    }
    
    func configureCustomCountdownCell(cell: PPLTableViewCell) {
        if let _ = cell.rootView.viewWithTag(2929) { return }
        cell.rootView.isUserInteractionEnabled = true
        let countdownLabel = labelForCountdown()
        cell.rootView.addSubview(countdownLabel)
        countdownLabel.tag = 2929
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -18).isActive = true
        countdownLabel.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        countdownLabel.widthAnchor.constraint(equalToConstant: 75).isActive = true
        countdownLabel.heightAnchor.constraint(equalToConstant: countdownLabel.frame.height).isActive = true
        cell.rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCountdownPicker)))
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
    
    
    func configureDefaultColorCell(cell: PPLTableViewCell) {
        if let _ = defaultColorView(cell) { return }
        cell.rootView.isUserInteractionEnabled = true
        let appThemeView = viewForAppColor()
        cell.rootView.addSubview(appThemeView)
        appThemeView.translatesAutoresizingMaskIntoConstraints = false
        appThemeView.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -18).isActive = true
        appThemeView.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        appThemeView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        appThemeView.heightAnchor.constraint(equalToConstant: cell.rootView.frame.height).isActive = true
        cell.rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDefaultColorPicker)))
        self.defaultColorView = appThemeView
    }
    
    @objc private func showDefaultColorPicker() {
        let pickerVC = PPLColorPickerViewController()
        pickerVC.modalPresentationStyle = .popover
        pickerVC.preferredContentSize = CGSize(width: 75, height: 250)
        pickerVC.popoverPresentationController?.sourceView = defaultColorView
        pickerVC.popoverPresentationController?.sourceRect = CGRect(x: defaultColorView.frame.width/2, y: 6, width: 0, height: defaultColorView.frame.height)
        pickerVC.popoverPresentationController?.delegate = self
        present(pickerVC, animated: true, completion: {
            pickerVC.$colorSelection.sink { [weak self] (value) in
                guard let color = value, let self = self else { return }
                PPLDefaults.instance.setDefaultColor(color)
                self.updateForNewDefaultColor()
                pickerVC.picker.backgroundColor = PPLColor.quaternary
                self.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
        })
    }
    
    func configureTimerSoundsCell(cell: PPLTableViewCell) {
        cell.rootView.isUserInteractionEnabled = true
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
        cell.rootView.addSubview(lbl)
        constrain(lbl, cell)
        return lbl
    }
    
    fileprivate func constrain(_ lbl: PPLNameLabel, _ cell: PPLTableViewCell) {
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
        lbl.leadingAnchor.constraint(equalTo: cell.rootView.leadingAnchor, constant: 20).isActive = true
        lbl.trailingAnchor.constraint(equalTo: nameLabelTrailingAnchor(cell.rootView), constant: 5).isActive = true
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
        guard let cell = tableView?.cellForRow(at: indexPath) as? PPLTableViewCell else { return }
        let spinner = UIActivityIndicatorView(frame: cell.rootView.frame)
        spinner.layer.cornerRadius = cell.rootView.layer.cornerRadius
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
        let vc = AboutViewController()
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
        if #available(iOS 14, *) {
            switchView.preferredStyle = .checkbox
        }
        switchView.layer.masksToBounds = true
        switchView.layer.borderWidth = 2.0
        switchView.layer.cornerRadius = 16
        switchView.layer.borderColor = PPLColor.darkGray.cgColor
        switchView.tintColor = PPLColor.black
        switchView.backgroundColor = .gray
        cell.rootView.addSubview(switchView)
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.trailingAnchor.constraint(equalTo: cell.rootView.trailingAnchor, constant: -20).isActive = true
        switchView.centerYAnchor.constraint(equalTo: cell.rootView.centerYAnchor).isActive = true
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
