//
//  WorkoutLogViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let WorkoutLogCellReuseIdentifier = "WorkoutLogCellReuseIdentifier"

class WorkoutLogViewController: PPLTableViewController {
    
    weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Workouts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbl = UITableView(frame: view.frame)
        view.addSubview(tbl)
        viewModel = WorkoutLogViewModel()
        tableView = tbl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WorkoutLogTableViewCell", bundle: nil), forCellReuseIdentifier: WorkoutLogCellReuseIdentifier)
        tableView.reloadData()
    }
    
    private func workoutLogViewModel() -> WorkoutLogViewModel {
        return viewModel as! WorkoutLogViewModel
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeaderView(titles: workoutLogViewModel().tableHeaderTitles())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutLogCellReuseIdentifier) as! WorkoutLogTableViewCell
        cell.nameLabel?.text = viewModel.title(indexPath: indexPath)
        cell.dateLabel?.text = workoutLogViewModel().dateLabel(indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkoutDataViewController()
        vc.viewModel = WorkoutReadViewModel(withCoreDataManagement: CoreDataManager.shared, workout: workoutLogViewModel().workouts[indexPath.row])
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

class WorkoutLogViewModel: NSObject, ViewModel {
    var workouts = [Workout]()
    let formatter = DateFormatter()
    
    init(withDataManager dataManager: WorkoutDataManager = WorkoutDataManager()) {
        super.init()
        formatter.dateFormat = "MM/dd/YY"
        workouts = WorkoutDataManager().workouts().sorted(by: {$0.dateCreated! > $1.dateCreated!})
    }
    
    func rowCount(section: Int) -> Int {
        return workouts.count
    }
    
    func title(indexPath: IndexPath) -> String? {
        return workouts[indexPath.row].name!
    }
    
    func dateLabel(indexPath: IndexPath) -> String? {
        return formatter.string(from: workouts[indexPath.row].dateCreated!)
    }
    
    func tableHeaderTitles() -> [String] {
        return ["Name", "Date"]
    }
}

class WorkoutLogTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}
