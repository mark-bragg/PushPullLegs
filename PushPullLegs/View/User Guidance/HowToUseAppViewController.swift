//
//  HowToUseAppViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 10/28/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class HowToUseAppViewController: PPLTableViewController {

    private let buttonTagConstant = 123
    private var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HowToUseAppViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard firstLoad else { return }
        firstLoad = false
    }
    
    override func addBannerView(size: STABannerSize) {
        // no op
    }
    
    override func bannerContainerHeight(size: STABannerSize) -> CGFloat {
        0
    }
    
    func howToUseAppViewModel() -> HowToUseAppViewModel {
        return viewModel as! HowToUseAppViewModel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        howToUseAppViewModel().sectionCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return howToUseAppViewModel().titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.contentView.backgroundColor = PPLColor.primary
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.text = howToUseAppViewModel().title(indexPath: indexPath)
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.font = tv.font?.withSize(20)
        howToUseAppViewModel().setHeight(heightForSection(indexPath.section, tv), forRow: indexPath.row)
        cell.contentView.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        tv.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        tv.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, constant: -32).isActive = true
        tv.heightAnchor.constraint(equalToConstant: howToUseAppViewModel().heightForRow(indexPath.row)).isActive = true
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
        if howToUseAppViewModel().isSectionExpanded(section) {
            return tv.sizeThatFits(CGSize(width: (tableView?.frame.size.width ?? 32) - 32, height: CGFloat.greatestFiniteMagnitude)).height
        }
        return 75
    }
    
    func addReadMoreButton(_ cell: UITableViewCell, section: Int) {
        var btn: CellExpansionButton
        if cell.contentView.subviews.contains(where: { $0.isKind(of: CellExpansionButton.self) }) {
            btn = cell.contentView.subviews.first(where: { $0.isKind(of: CellExpansionButton.self) }) as! CellExpansionButton
        } else {
            btn = CellExpansionButton(type: .roundedRect)
        }
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.tag = section + buttonTagConstant
        btn.isCollapsed = !howToUseAppViewModel().isSectionExpanded(section)
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
        let rowToScrollTo = button.isCollapsed ? section : 0
        if button.isCollapsed {
            howToUseAppViewModel().collapseEverythingExcept(section)
        } else {
            howToUseAppViewModel().collapseSection(section)
        }
        tableView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.tableView?.scrollToRow(at: IndexPath(row: 0, section: rowToScrollTo), at: .top, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return howToUseAppViewModel().heightForRow(indexPath.row)
    }

}

class CellExpansionButton: UIButton {
    var indexPath: IndexPath?
    var isCollapsed = true {
        willSet {
            setTitle(newValue ? "Continue Reading" : "Finished", for: .normal)
        }
    }
}
