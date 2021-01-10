//
//  WorkoutLogViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

class HeaderViewContainer: UIView {
    var headerView: UIView! {
        willSet {
            addSubview(newValue)
        }
    }
}

let WorkoutLogCellReuseIdentifier = "WorkoutLogCellReuseIdentifier"

class WorkoutLogViewController: PPLTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WorkoutLogViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = .clear
        reload()
    }
    
    private func workoutLogViewModel() -> WorkoutLogViewModel {
        return viewModel as! WorkoutLogViewModel
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = tableHeaderViewContainer(titles: workoutLogViewModel().tableHeaderTitles())
        guard let header = container.headerView else { return nil }
        let leftLabel = header.subviews.first(where: { $0.frame.origin.x == 0 })!
        let rightLabel = header.subviews.first(where: { $0.frame.origin.x != 0 })!
        containerizeDateLabel(header, rightLabel as! UILabel)
        leftLabel.frame = CGRect(x: 20, y: leftLabel.frame.origin.y, width: leftLabel.frame.width - 20, height: leftLabel.frame.height)
        rightLabel.frame = CGRect(x: leftLabel.frame.width + 20, y: rightLabel.frame.origin.y, width: rightLabel.frame.width - 20, height: leftLabel.frame.height)
        return container
    }
    
    func containerizeDateLabel(_ headerView: UIView, _ label: UILabel) {
        let container = UIView(frame: label.frame)
        headerView.addSubview(container)
        label.removeFromSuperview()
        container.addSubview(label)
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        addArrowImage(label)
        if let grs = container.gestureRecognizers, grs.count == 0 { return }
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateHeaderTapped)))
        container.isUserInteractionEnabled = true
    }
    
    func addArrowImage(_ label: UIView) {
        let down = UIImage(systemName: "arrowtriangle.down.fill")
        let up = UIImage(systemName: "arrowtriangle.up.fill")
        let img = UIImageView(image: down, highlightedImage: up)
        img.sizeToFit()
        img.tintColor = .lightGray
        label.addSubview(img)
        dateArrow = img
        dateArrow.isHighlighted = WorkoutLogViewModel.ascending
        positionDateArrow(label)
    }
    
    func positionDateArrow(_ label: UIView) {
        dateArrow.translatesAutoresizingMaskIntoConstraints = false
        dateArrow.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        dateArrow.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
    }
    
    weak var dateArrow: UIImageView!
    @objc func dateHeaderTapped() {
        WorkoutLogViewModel.ascending = !WorkoutLogViewModel.ascending
        dateArrow.isHighlighted = WorkoutLogViewModel.ascending
        reload()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkoutDataViewController()
        vc.viewModel = WorkoutReadViewModel(withCoreDataManagement: CoreDataManager.shared, workout: workoutLogViewModel().workouts[indexPath.row])
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func reload() {
        viewModel = WorkoutLogViewModel()
        super.reload()
    }
    
//    override func adUnitID() -> String {
//        
//    }

}

class WorkoutLogViewModel: NSObject, PPLTableViewModel {
    var workouts = [Workout]()
    let formatter = DateFormatter()
    static var ascending = false
    
    init(withDataManager dataManager: WorkoutDataManager = WorkoutDataManager()) {
        super.init()
        formatter.dateFormat = "MM/dd/yy"
        workouts = WorkoutDataManager().workouts()
        if WorkoutLogViewModel.ascending {
            workouts.reverse()
        }
    }
    
    func rowCount(section: Int) -> Int {
        return workouts.count
    }
    
    func title() -> String? {
        return "Workout Log"
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
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        textColor = .textGreen
        font = UIFont.systemFont(ofSize: 23, weight: .medium)
    }
}
