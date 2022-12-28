//
//  PPLDropDownViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

@objc
protocol PPLDropdownViewControllerDelegate: NSObjectProtocol {
    func didSelectItem(_ item: PPLDropdownItem)
    
    @objc optional
    func didSelectDates(_ startDate: Date, _ endDate: Date)
}

protocol PPLDropdownViewControllerDataSource: NSObject {
    func dropdownItems() -> [PPLDropdownItem]
}

class PPLDropdownItem: NSObject {
    let target: AnyObject?
    let action: Selector?
    let name: String
    
    init(target: AnyObject?, action: Selector?, name: String) {
        self.target = target
        self.action = action
        self.name = name
    }
}

class PPLDropdownNavigationItem: PPLDropdownItem {
    var items: [PPLDropdownItem]
    
    init(items: [PPLDropdownItem], name: String) {
        self.items = items
        super.init(target: nil, action: nil, name: name)
    }
}

class PPLDropdownDateNavigationItem: PPLDropdownNavigationItem {
    var firstDate: Date
    var secondDate: Date
    var minDate: Date
    var maxDate: Date
    
    init(firstDate: Date, secondDate: Date, minDate: Date, maxDate: Date) {
        self.firstDate = firstDate
        self.secondDate = secondDate
        self.minDate = minDate
        self.maxDate = maxDate
        super.init(items: [PPLDropdownDateItem(minDate: minDate, maxDate: maxDate, currentDate: firstDate), PPLDropdownDateItem(minDate: firstDate, maxDate: secondDate, currentDate: secondDate)], name: "Select Dates")
    }
}

class PPLDropdownDateItem: PPLDropdownItem {
    let minDate: Date
    let maxDate: Date
    let currentDate: Date
    
    init(minDate: Date, maxDate: Date, currentDate: Date) {
        self.minDate = minDate
        self.maxDate = maxDate
        self.currentDate = currentDate
        super.init(target: nil, action: nil, name: "")
    }
}

private let maxTableHeight: CGFloat = 300
private let rowHeight: CGFloat = 50

class PPLDropDownContainerViewController: UIViewController {
    var items: [PPLDropdownItem]? { presentedDropdown?.items ?? dataSource?.dropdownItems() }
    weak var delegate: PPLDropdownViewControllerDelegate?
    weak var dataSource: PPLDropdownViewControllerDataSource?
    weak var navigator: PPLNavigationController?
    private var presentedDropdown: PPLDropDownViewController? {
        navigator?.viewControllers.first as? PPLDropDownViewController
    }
    var rowsByRowHeight: CGFloat { rowHeight * CGFloat((items ?? []).count) }
    private var preferredHeight: CGFloat { rowsByRowHeight }
    
    func calculateHeight(_ items: [PPLDropdownItem]?) -> CGFloat {
        rowHeight * CGFloat((items ?? []).count)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavigator()
        populateRootMenu()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let height = preferredHeight
        preferredContentSize = CGSize(width: 200, height: height)
        navigator?.isNavigationBarHidden = true
    }
    
    private func addNavigator() {
        let nav = PPLNavigationController(rootViewController: PPLDropDownViewController())
        addChild(nav)
        nav.view.frame = view.bounds
        view.addSubview(nav.view)
        nav.didMove(toParent: self)
        nav.delegate = self
        navigator = nav
    }
    
    private func populateRootMenu() {
        presentedDropdown?.delegate = self
        presentedDropdown?.dataSource = dataSource
    }
}

extension PPLDropDownContainerViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        view.setNeedsLayout()
        if let dropdown = viewController as? PPLDropDownViewController {
            preferredContentSize = CGSize(width: 200, height: calculateHeight(dropdown.items))
        }
    }
}

extension PPLDropDownContainerViewController: PPLDropdownViewControllerDelegate {
    func didSelectItem(_ item: PPLDropdownItem) {
        if let item = item as? PPLDropdownNavigationItem {
            addNewDropdownMenu(item.items)
        } else if let delegate {
            delegate.didSelectItem(item)
        }
    }
    
    private func addNewDropdownMenu(_ items: [PPLDropdownItem]) {
        let newMenu = PPLDropDownViewController()
        newMenu.delegate = self
        newMenu.items = items
        navigator?.pushViewController(newMenu, animated: true)
    }
    
    func didSelectDates(_ startDate: Date, _ endDate: Date) {
        delegate?.didSelectDates?(startDate, endDate)
    }
}

private class PPLDropDownViewController: UIViewController {

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

extension PPLDropDownViewController: UITableViewDelegate {
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

extension PPLDropDownViewController: UITableViewDataSource {
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
