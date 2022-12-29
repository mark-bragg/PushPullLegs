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

let maxTableHeight: CGFloat = 300
let rowHeight: CGFloat = 50

class PPLDropDownViewController: UIViewController {
    var items: [PPLDropdownItem]? { presentedDropdownMenu?.items ?? dataSource?.dropdownItems() }
    weak var delegate: PPLDropdownViewControllerDelegate?
    weak var dataSource: PPLDropdownViewControllerDataSource?
    weak var navigator: PPLNavigationController?
    private var presentedDropdownMenu: PPLDropdownMenu? {
        navigator?.viewControllers.first as? PPLDropdownMenu
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
        let nav = PPLNavigationController(rootViewController: PPLDropdownMenu())
        addChild(nav)
        nav.view.frame = view.bounds
        view.addSubview(nav.view)
        nav.didMove(toParent: self)
        nav.delegate = self
        navigator = nav
    }
    
    private func populateRootMenu() {
        presentedDropdownMenu?.delegate = self
        presentedDropdownMenu?.dataSource = dataSource
    }
}

extension PPLDropDownViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        view.setNeedsLayout()
        if let dropdown = viewController as? PPLDropdownMenu {
            preferredContentSize = CGSize(width: 200, height: calculateHeight(dropdown.items))
        }
    }
}

extension PPLDropDownViewController: PPLDropdownViewControllerDelegate {
    func didSelectItem(_ item: PPLDropdownItem) {
        if let item = item as? PPLDropdownNavigationItem {
            addNewDropdownMenu(item.items)
        } else if let delegate {
            delegate.didSelectItem(item)
        } else if let action = item.action {
            presentationController?.presentedViewController.dismiss(animated: true) {
                let _ = item.target?.perform(action)
            }
        }
    }
    
    private func addNewDropdownMenu(_ items: [PPLDropdownItem]) {
        let newMenu = PPLDropdownMenu()
        newMenu.delegate = self
        newMenu.items = items
        navigator?.pushViewController(newMenu, animated: true)
    }
    
    func didSelectDates(_ startDate: Date, _ endDate: Date) {
        delegate?.didSelectDates?(startDate, endDate)
    }
}
