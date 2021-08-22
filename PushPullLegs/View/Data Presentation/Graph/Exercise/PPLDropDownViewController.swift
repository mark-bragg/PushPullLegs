//
//  PPLDropDownViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit

protocol PPLDropdownViewControllerDelegate: NSObject {
    func didSelectName(_ name: String)
}

protocol PPLDropdownViewControllerDataSource: NSObject {
    func names() -> [String]
}

class PPLDropDownViewController: UIViewController {

    var names: [String]!
    weak var delegate: PPLDropdownViewControllerDelegate?
    weak var dataSource: PPLDropdownViewControllerDataSource!
    private let rowHeight: CGFloat = 40
    private var tableHeight: CGFloat { rowsByRowHeight > maxTableHeight ? maxTableHeight : rowsByRowHeight }
    private let maxTableHeight: CGFloat = 300
    private var rowsByRowHeight: CGFloat { rowHeight * CGFloat(names.count) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        names = dataSource.names()
        view.backgroundColor = PPLColor.quaternary
        let tblv = UITableView()
        tblv.backgroundColor = PPLColor.clear
        tblv.delegate = self
        tblv.dataSource = self
        constrainTableView(tblv)
        tblv.rowHeight = rowHeight
        tblv.isScrollEnabled = tableHeight == maxTableHeight
        preferredContentSize = CGSize(width: 200, height: tableHeight + 24)
    }
    
    func constrainTableView(_ tblv: UITableView) {
        view.addSubview(tblv)
        tblv.translatesAutoresizingMaskIntoConstraints = false
        tblv.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        tblv.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true
        tblv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tblv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

}

extension PPLDropDownViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectName(names[indexPath.item])
    }
}

extension PPLDropDownViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = names[indexPath.item]
        cell.textLabel?.textColor = PPLColor.text
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
}
