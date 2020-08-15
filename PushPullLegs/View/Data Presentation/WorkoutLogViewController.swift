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
        let header = tableHeaderView(titles: workoutLogViewModel().tableHeaderTitles())
        let leftLabel = header.subviews.first(where: { $0.frame.origin.x == 0 })!
        let rightLabel = header.subviews.first(where: { $0.frame.origin.x != 0 })!
        leftLabel.frame = CGRect(x: 20, y: leftLabel.frame.origin.y, width: leftLabel.frame.width - 20, height: leftLabel.frame.height)
        rightLabel.frame = CGRect(x: leftLabel.frame.width + 20, y: rightLabel.frame.origin.y, width: rightLabel.frame.width - 20, height: leftLabel.frame.height)
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.rootView.removeAllSubviews()
        let contentFrame = cell.rootView.frame
        let nameLabel = PPLNameLabel(frame: CGRect(x: 20, y: 0, width: tableView.frame.width / 2 - 20, height: contentFrame.height))
        let dateLabel = PPLNameLabel(frame: CGRect(x: nameLabel.frame.width + 20, y: 0, width: tableView.frame.width / 2 - 20, height: contentFrame.height))
        nameLabel.text = viewModel.title(indexPath: indexPath)
        dateLabel.text = workoutLogViewModel().dateLabel(indexPath: indexPath)
        for lbl in [nameLabel, dateLabel] {
            lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            lbl.textAlignment = .center
            cell.rootView.addSubview(lbl)
        }
        cell.addDisclosureIndicator()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkoutDataViewController()
        vc.viewModel = WorkoutReadViewModel(withCoreDataManagement: CoreDataManager.shared, workout: workoutLogViewModel().workouts[indexPath.row])
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

}

class WorkoutLogViewModel: NSObject, PPLTableViewModel {
    var workouts = [Workout]()
    let formatter = DateFormatter()
    
    init(withDataManager dataManager: WorkoutDataManager = WorkoutDataManager()) {
        super.init()
        formatter.dateFormat = "MM/dd/YY"
        workouts = WorkoutDataManager().workouts()
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
