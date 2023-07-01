//
//  WorkoutLogViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 4/21/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class HeaderViewContainer: UITableViewHeaderFooterView {
    weak var headerView: UIView? {
        willSet {
            guard let newValue else { return }
            addSubview(newValue)
        }
    }
}

let WorkoutLogCellReuseIdentifier = "WorkoutLogCellReuseIdentifier"

class WorkoutLogViewController: DatabaseTableViewController {
    
    private var workoutLogViewModel: WorkoutLogViewModel? {
        get { viewModel as? WorkoutLogViewModel }
        set { viewModel = newValue }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel = WorkoutLogViewModel()
        super.viewWillAppear(animated)
        tableView?.backgroundColor = .clear
        reload()
    }
    
    override func addAction() {
        presentAddWorkoutSelection()
    }
    
    func presentAddWorkoutSelection() {
        let vc = StartWorkoutViewController()
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let workoutLogViewModel else { return nil }
        let container = tableHeaderViewContainer(titles: workoutLogViewModel.tableHeaderTitles())
        guard
            let header = container.headerView,
            let leftLabel = header.subviews.first(where: { $0.frame.origin.x == 0 }),
            let rightLabel = header.subviews.first(where: { $0.frame.origin.x != 0 }) as? UILabel
        else { return nil }
        containerizeDateLabel(header, rightLabel)
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
        dateArrow?.isHighlighted = WorkoutLogViewModel.ascending
        positionDateArrow(label)
    }
    
    func positionDateArrow(_ label: UIView) {
        dateArrow?.translatesAutoresizingMaskIntoConstraints = false
        dateArrow?.centerYAnchor.constraint(equalTo: label.centerYAnchor).isActive = true
        dateArrow?.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
    }
    
    weak var dateArrow: UIImageView?
    @objc func dateHeaderTapped() {
        WorkoutLogViewModel.ascending = !WorkoutLogViewModel.ascending
        dateArrow?.isHighlighted = WorkoutLogViewModel.ascending
        reload()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier) else {
            return UITableViewCell()
        }
        cell.nameLabel.text = viewModel?.title(indexPath: indexPath)
        cell.dateLabel.text = workoutLogViewModel?.dateLabel(indexPath: indexPath)
        cell.nameLabel.textColor = PPLColor.text
        cell.dateLabel.textColor = PPLColor.text
        if !tableView.isEditing {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let workoutLogViewModel else { return }
        let vc = WorkoutDataViewController()
        vc.viewModel = WorkoutDataViewModel(withCoreDataManagement: CoreDataManager.shared, workout: workoutLogViewModel.dbObjects[indexPath.row] as? Workout)
        
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func headerLabelWidth(_ headerWidth: CGFloat, _ numberOfTitles: CGFloat) -> CGFloat {
        guard let tableView, let visibleIndexPath = tableView.indexPathsForVisibleRows?.first else {
            return super.headerLabelWidth(headerWidth, numberOfTitles)
        }
        let cell = self.tableView(tableView, cellForRowAt: visibleIndexPath)
        return (cell.contentView.frame.width / numberOfTitles)
    }
    
    override func reload() {
        viewModel = WorkoutLogViewModel()
        workoutLogViewModel?.reloader = self
        super.reload()
        self.tableView?.beginUpdates()
        tableView?.reloadData()
        self.tableView?.endUpdates()
        if let selectedIndex = workoutLogViewModel?.selectedIndex {
            workoutLogViewModel?.selectedIndex = nil
            tableView((tableView ?? UITableView()), didSelectRowAt: IndexPath(row: selectedIndex, section: 0))
        }
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
        font = UIFont.systemFont(ofSize: 23, weight: .medium)
    }
}

fileprivate extension UITableViewCell {
    private var nameTag: Int {529}
    private var dateTag: Int {232}
    
    var nameLabel: PPLNameLabel {
        get {
            if let lbl = viewWithTag(nameTag) as? PPLNameLabel {
                return lbl
            }
            let nameLabel = PPLNameLabel()
            nameLabel.tag = nameTag
            addLabel(nameLabel)
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
            return nameLabel
        }
    }
    
    var dateLabel: PPLNameLabel {
        get {
            if let lbl = viewWithTag(dateTag) as? PPLNameLabel {
                return lbl
            }
            let dateLabel = PPLNameLabel()
            dateLabel.tag = dateTag
            addLabel(dateLabel)
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5).isActive = true
            return dateLabel
        }
    }
    
    func addLabel(_ label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

extension WorkoutLogViewController: WorkoutSelectionDelegate {
    func workoutSelectedWithType(_ type: ExerciseTypeName) {
        WorkoutDataManager().create(name: type.rawValue, keyValuePairs: ["dateCreated": Date()])
        dismiss(animated: true, completion: nil)
        reload()
        if let workoutLogViewModel {
            let row = WorkoutLogViewModel.ascending ? workoutLogViewModel.rowCount(section: 0) - 1 : 0
            tableView((tableView ?? UITableView()), didSelectRowAt: IndexPath(row: row, section: 0))
        }
    }
}
