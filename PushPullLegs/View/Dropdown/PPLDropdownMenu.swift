//
//  PPLDropdownMenu.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/28/22.
//  Copyright © 2022 Mark Bragg. All rights reserved.
//

import Foundation

class PPLDropdownMenu: UIViewController {

    var items: [PPLDropdownItem]?
    weak var delegate: PPLDropdownViewControllerDelegate?
    weak var dataSource: PPLDropdownViewControllerDataSource?
    var tableHeight: CGFloat { rowsByRowHeight > maxTableHeight ? maxTableHeight : rowsByRowHeight }
    var rowsByRowHeight: CGFloat { rowHeight * CGFloat((items ?? []).count) }
    weak var startDatePicker: UIDatePicker?
    weak var endDatePicker: UIDatePicker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let dataSource {
            items = dataSource.dropdownItems()
        }
        view.backgroundColor = PPLColor.secondary
        let tblv = UITableView()
        tblv.backgroundColor = PPLColor.clear
        tblv.delegate = self
        tblv.dataSource = self
        constrainTableView(tblv)
        tblv.rowHeight = rowHeight
        tblv.isScrollEnabled = tableHeight == maxTableHeight
        tblv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func constrainTableView(_ tblv: UITableView) {
        view.addSubview(tblv)
        tblv.translatesAutoresizingMaskIntoConstraints = false
        tblv.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        tblv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tblv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tblv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}

extension PPLDropdownMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let items else { return }
        let item = items[indexPath.row]
        if let delegate {
            delegate.didSelectItem(item)
        } else if let action = item.action {
            let _ = item.target?.perform(action)
        }
    }
}

extension PPLDropdownMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        let lbl = UILabel()
        if let item = items?[indexPath.row] {
            if let item = item as? PPLDropdownDateItem {
                let picker = newDatePicker(item.minDate, item.maxDate, item.currentDate)
                if indexPath.row == 0 {
                    startDatePicker = picker
                } else {
                    endDatePicker = picker
                }
                cell.contentView.addSubview(picker)
                constrain(picker, toInsideOf: cell.contentView)
            } else {
                lbl.text = "\(item.name)"
                if item.isKind(of: PPLDropdownNavigationItem.self) {
                    cell.accessoryType = .disclosureIndicator
                }
            }
        }
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.textAlignment = .center
        cell.contentView.addSubview(lbl)
        constrain(lbl, toInsideOf: cell.contentView)
        lbl.backgroundColor = .clear
        return cell
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let startDatePicker, let endDatePicker {
            delegate?.didSelectDates?(startDatePicker.date, endDatePicker.date)
        }
    }
    
    private func newDatePicker(_ minDate: Date, _ maxDate: Date, _ currentDate: Date) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = minDate
        picker.maximumDate = maxDate
        picker.date = currentDate
        return picker
    }
}
