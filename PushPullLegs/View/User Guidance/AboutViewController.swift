//
//  AboutViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class AboutViewController: PPLTableViewController {

    private let buttonTagConstant = 123
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AboutViewModel()
    }
    
    func aboutViewModel() -> AboutViewModel {
        return viewModel as! AboutViewModel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        aboutViewModel().sectionCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return aboutViewModel().titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = PPLColor.grey
        let tv = UITextView()
        tv.backgroundColor = PPLColor.offWhite
        tv.textColor = .black
        tv.text = aboutViewModel().title(indexPath: indexPath)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.font = tv.font?.withSize(20)
        aboutViewModel().setHeight(heightForSection(indexPath.section, tv), forRow: indexPath.row)
        cell.contentView.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        tv.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        tv.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, constant: -32).isActive = true
        tv.heightAnchor.constraint(equalToConstant: aboutViewModel().heightForRow(indexPath.row)).isActive = true
        if let btn = buttonForCell(cell) {
            cell.contentView.bringSubviewToFront(btn)
        } else {
            
        }
        addReadMoreButton(cell, section: indexPath.section)
        return cell
    }
    
    func buttonForCell(_ cell: UITableViewCell) -> UIView? {
        return cell.contentView.subviews.first(where: { $0.isKind(of: CellExpansionButton.self) })
    }
    
    private func heightForSection(_ section: Int, _ tv: UITextView) -> CGFloat {
        var size: CGSize
        if aboutViewModel().isSectionExpanded(section) {
            size = tv.sizeThatFits(CGSize(width: tableView.frame.size.width - 32, height: CGFloat.greatestFiniteMagnitude))
        } else {
            size = CGSize(width: 0, height: 75)
        }
        return size.height
    }
    
    func addReadMoreButton(_ cell: UITableViewCell, section: Int) {
        var btn: CellExpansionButton
        if cell.contentView.subviews.contains(where: { $0.isKind(of: CellExpansionButton.self) }) {
            btn = cell.contentView.subviews.first(where: { $0.isKind(of: CellExpansionButton.self) }) as! CellExpansionButton
        } else {
            btn = CellExpansionButton(type: .roundedRect)
        }
        btn.tag = section + buttonTagConstant
        btn.isCollapsed = !aboutViewModel().isSectionExpanded(section)
        btn.sizeToFit()
        cell.contentView.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        btn.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        if btn.target(forAction: #selector(expandCollapseCell(_:)), withSender: btn) == nil {
            btn.addTarget(self, action: #selector(expandCollapseCell), for: .touchUpInside)
        }
    }
    
    @objc func expandCollapseCell(_ button: CellExpansionButton) {
        let section = button.tag - buttonTagConstant
        if button.isCollapsed {
            aboutViewModel().expandSection(section)
        } else {
            aboutViewModel().collapseSection(section)
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return aboutViewModel().heightForRow(indexPath.row)
    }

}

class CellExpansionButton: UIButton {
    var indexPath: IndexPath?
    var isCollapsed = true {
        willSet {
            setTitle(newValue ? "Read More" : "Read Less", for: .normal)
        }
    }
}