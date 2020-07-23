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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tbl = PPLTableView()
        view.addSubview(tbl)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.rowHeight = 75
        tableView = tbl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel = WorkoutLogViewModel()
        tableView.backgroundColor = .clear
        constrainToView(tableView)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.rootView.removeAllSubviews()
        let contentFrame = cell.rootView.frame
        let nameLabel = PPLNameLabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width / 2, height: contentFrame.height))
        let dateLabel = PPLNameLabel(frame: CGRect(x: nameLabel.frame.width, y: 0, width: tableView.frame.width / 2, height: contentFrame.height))
        nameLabel.text = viewModel.title(indexPath: indexPath)
        dateLabel.text = workoutLogViewModel().dateLabel(indexPath: indexPath)
        for lbl in [nameLabel, dateLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textAlignment = .center
            cell.rootView.addSubview(lbl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
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

class PPLNameLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = PPLColor.textBlue
        font = UIFont.systemFont(ofSize: 23, weight: .medium)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textColor = PPLColor.textBlue
        font = UIFont.systemFont(ofSize: 23, weight: .medium)
    }
}


extension UIViewController {
    func constrainToView(_ subview: UIView) {
        let guide = view.safeAreaLayoutGuide
        subview.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        subview.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }
}
