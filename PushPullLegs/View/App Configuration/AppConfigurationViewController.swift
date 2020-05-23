//
//  AppConfigurationViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let defaultCellIdentifier = "DefaultTableViewCell"

class AppConfigurationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultCellIdentifier)
        navigationItem.title = "Settings"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.hidesBottomBarWhenPushed = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellIdentifier) else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0:
            configureEditWorkoutList(cell: cell)
        case 1:
            configureEditExerciseList(cell: cell)
        case 2:
            configureStartNextWorkoutPromptSwitch(cell: cell)
            cell.selectionStyle = .none
        default:break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let segueId = segueIdentifierForRow(indexPath.row) {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: segueId.rawValue, sender: self)
        }
    }
    
    func segueIdentifierForRow(_ row: Int) -> SegueIdentifier? {
        switch row {
        case 0: return SegueIdentifier.editWorkoutList
        case 1: return SegueIdentifier.editExerciseList
        default: break
        }
        return nil
    }
    
    func configureEditWorkoutList(cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Edit Workout List"
    }
    
    func configureEditExerciseList(cell: UITableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = "Edit Exercise List"
    }
    
    func configureStartNextWorkoutPromptSwitch(cell: UITableViewCell) {
        let switchView = UISwitch()
        switchView.setOn(PPLDefaults.instance.workoutTypePromptSwitchValue(), animated: false)
        switchView.addTarget(self, action: #selector(toggleWorkoutTypePromptValue), for: .valueChanged)
        cell.accessoryView = switchView
        cell.textLabel?.text = "Prompt for workout type when starting next workout"
        
    }

    @objc func toggleWorkoutTypePromptValue() {
        PPLDefaults.instance.toggleWorkoutTypePromptValue()
    }
    
}

class PPLDefaults: NSObject {
    let user_details_suite_name = "User Details"
    let prompt_user_for_workout_type = "Prompt User For Workout Type"
    let kUserDetailsPromptForWorkoutType = "kUserDetailsPromptForWorkoutType"
    override private init() {
        super.init()
        setupUserDetails()
    }
    static let instance = PPLDefaults()
    private var userDetails: UserDefaults!
    
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
