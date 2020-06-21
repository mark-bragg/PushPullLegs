//
//  AppConfigurationViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let defaultCellIdentifier = "DefaultTableViewCell"

class AppConfigurationViewController: PPLTableViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AppConfigurationViewModel()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        navigationItem.title = "Settings"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier) else {
            return UITableViewCell()
        }
        if indexPath.row == 2 {
            configureKilogramsPoundsSwitch(cell: cell)
        } else if indexPath.row == 3 {
            configureStartNextWorkoutPromptSwitch(cell: cell)
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        cell.textLabel?.text = viewModel.title(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueId = segueIdentifierForRow(indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
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
    
    func configureKilogramsPoundsSwitch(cell: UITableViewCell) {
        let switchView = UISwitch()
        switchView.setOn(PPLDefaults.instance.isKilograms(), animated: false)
        switchView.addTarget(self, action: #selector(toggleKilogramsPoundsValue(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        cell.selectionStyle = .none
    }

    @objc func toggleKilogramsPoundsValue(_ switchView: UISwitch) {
        let isKilograms = PPLDefaults.instance.isKilograms()
        var title = "Change Unit from "
        if isKilograms {
            title.append("Kilograms to Pounds?")
        } else {
            title.append("Pounds to Kilograms?")
        }
        let message = "This may take some time to update the database"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            PPLDefaults.instance.toggleKilograms()
            self.tableView.reloadData()
            // TODO: update database, present spinner for duration of update
            let spinner = UIActivityIndicatorView(frame: self.view.frame)
            spinner.style = .large
            let fxView = UIVisualEffectView(frame: self.view.frame)
            fxView.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
            self.tabBarController?.tabBar.isHidden = true
            fxView.contentView.addSubview(spinner)
            self.view.addSubview(fxView)
            spinner.startAnimating()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            switchView.setOn(!switchView.isOn, animated: true)
        }))
        present(alert, animated: true)
    }
    
    func configureStartNextWorkoutPromptSwitch(cell: UITableViewCell) {
        let switchView = UISwitch()
        switchView.setOn(PPLDefaults.instance.workoutTypePromptSwitchValue(), animated: false)
        switchView.addTarget(self, action: #selector(toggleWorkoutTypePromptValue), for: .valueChanged)
        cell.accessoryView = switchView
        cell.selectionStyle = .none
    }

    @objc func toggleWorkoutTypePromptValue() {
        PPLDefaults.instance.toggleWorkoutTypePromptValue()
        tableView.reloadData()
    }
    
}

class AppConfigurationViewModel: NSObject, ViewModel {
    func rowCount(section: Int) -> Int {
        return 4
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
        default:
            if PPLDefaults.instance.workoutTypePromptSwitchValue() {
                return "Custom Workout Choice"
            }
            return "Start Next Workout in Program"
        }
    }
    
    
}

class PPLDefaults: NSObject {
    private let user_details_suite_name = "User Details"
    private let prompt_user_for_workout_type = "Prompt User For Workout Type"
    private let kUserDetailsKilogramsPounds = "kUserDetailsKilogramsPounds"
    private let kUserDetailsPromptForWorkoutType = "kUserDetailsPromptForWorkoutType"
    private let kWorkoutInProgress = "kWorkoutInProgress"
    private let kIsInstalled = "kIsInstalled"
    override private init() {
        super.init()
        setupUserDetails()
    }
    static let instance = PPLDefaults()
    private var userDetails: UserDefaults!
    
    private func isInstalled() -> Bool {
        let isInstalled = userDetails.bool(forKey: kIsInstalled)
        if !isInstalled {
            userDetails.set(false, forKey: kUserDetailsKilogramsPounds)
            userDetails.set(true, forKey: kIsInstalled)
        }
        return isInstalled
    }
    
    func isKilograms() -> Bool {
        if isInstalled() {
            return userDetails.bool(forKey: kUserDetailsKilogramsPounds)
        }
        return false
    }
    
    @objc func toggleKilograms() {
        let newValue = !userDetails.bool(forKey: kUserDetailsKilogramsPounds)
        userDetails.set(newValue, forKey: kUserDetailsKilogramsPounds)
    }
    
    func isWorkoutInProgress() -> Bool {
        return userDetails.bool(forKey: kWorkoutInProgress)
    }
    
    func setWorkoutInProgress(_ value: Bool) {
        userDetails.set(value, forKey: kWorkoutInProgress)
    }
    
    func workoutTypePromptSwitchValue() -> Bool {
        return userDetails.bool(forKey: kUserDetailsPromptForWorkoutType)
    }
    
    func setupUserDetails() {
        if let details = UserDefaults(suiteName: user_details_suite_name) {
            userDetails = details
        } else {
            UserDefaults.standard.addSuite(named: user_details_suite_name)
            addWorkoutTypePromptBool()
            setupUserDetails()
        }
    }
    
    func addWorkoutTypePromptBool() {
        userDetails.set(true, forKey: kUserDetailsPromptForWorkoutType)
    }
    
    @objc func toggleWorkoutTypePromptValue() {
        let newValue = !userDetails.bool(forKey: kUserDetailsPromptForWorkoutType)
        userDetails.set(newValue, forKey: kUserDetailsPromptForWorkoutType)
    }
}
