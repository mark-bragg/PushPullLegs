//
//  WorkoutLogViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let WorkoutLogCellReuseIdentifier = "WorkoutLogCellReuseIdentifier"

class WorkoutLogViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var tableView: UITableView!
    var workouts = [Workout]()
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.dateFormat = "MM/dd/YY"
        navigationItem.title = "Workouts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tbl = UITableView(frame: view.frame)
        view.addSubview(tbl)
        tableView = tbl
        tableView.rowHeight = 75.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "WorkoutLogTableViewCell", bundle: nil), forCellReuseIdentifier: WorkoutLogCellReuseIdentifier)
        workouts = WorkoutDataManager().workouts().sorted(by: {$0.dateCreated! > $1.dateCreated!})
        tableView.reloadData()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 60))
        let nameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width/2.0, height: 40))
        nameTitle.text = "Name"
        let dateTitle = UILabel(frame: CGRect(x: nameTitle.frame.width, y: 0, width: view.frame.width/2.0, height: 40))
        dateTitle.text = "Date"
        for lbl in [dateTitle, nameTitle] {
            lbl.textAlignment = .center
            lbl.font = UIFont.systemFont(ofSize: 23, weight: .semibold)
            view.addSubview(lbl)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutLogCellReuseIdentifier) as! WorkoutLogTableViewCell
        cell.nameLabel?.text = workouts[indexPath.row].name!
        cell.dateLabel?.text = formatter.string(from: workouts[indexPath.row].dateCreated!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkoutDataViewController()
        vc.viewModel = WorkoutReadViewModel(withCoreDataManagement: CoreDataManager.shared, workout: workouts[indexPath.row])
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

class WorkoutLogTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
}
