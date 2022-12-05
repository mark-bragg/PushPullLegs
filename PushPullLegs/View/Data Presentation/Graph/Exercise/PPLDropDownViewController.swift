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

    var names: [String]?
    weak var delegate: PPLDropdownViewControllerDelegate?
    weak var dataSource: PPLDropdownViewControllerDataSource?
    private let rowHeight: CGFloat = 50
    private var tableHeight: CGFloat { rowsByRowHeight > maxTableHeight ? maxTableHeight : rowsByRowHeight }
    private let maxTableHeight: CGFloat = 300
    private var rowsByRowHeight: CGFloat { rowHeight * CGFloat((names ?? []).count) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        names = dataSource?.names()
        view.backgroundColor = PPLColor.secondary
        let tblv = UITableView()
        tblv.backgroundColor = PPLColor.clear
        tblv.delegate = self
        tblv.dataSource = self
        constrainTableView(tblv)
        tblv.rowHeight = rowHeight
        tblv.isScrollEnabled = tableHeight == maxTableHeight
        preferredContentSize = CGSize(width: 200, height: tableHeight)
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
        guard let names else { return }
        delegate?.didSelectName(names[indexPath.item])
    }
}

extension PPLDropDownViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        names?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        let lbl = UILabel()
        if let names {
            lbl.text = "\(names[indexPath.item])"
        }
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.textAlignment = .center
        cell.contentView.addSubview(lbl)
        constrain(lbl, toInsideOf: cell.contentView)
        lbl.backgroundColor = .clear
        return cell
    }
}
