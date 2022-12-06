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
        tableView?.showsVerticalScrollIndicator = true
    }
    
    override func addBannerView(size: STABannerSize) {
        // no op
    }
    
    override func bannerContainerHeight(size: STABannerSize) -> CGFloat {
        0
    }
    
    func howToUseAppViewModel() -> HowToUseAppViewModel {
        viewModel as? HowToUseAppViewModel ?? HowToUseAppViewModel()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        howToUseAppViewModel().sectionCount()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        howToUseAppViewModel().titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
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
        tv.font = UIFont.systemFont(ofSize: 20)
        
        howToUseAppViewModel().setHeight(heightForSection(indexPath.section, tv), forRow: indexPath.row)
        cell.contentView.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        tv.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        tv.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, constant: -32).isActive = true
        tv.heightAnchor.constraint(equalToConstant: howToUseAppViewModel().heightForRow(indexPath.row)).isActive = true
        return cell
    }
    
    func buttonForCell(_ cell: UITableViewCell) -> UIView? {
        cell.contentView.subviews.first(where: { $0.isKind(of: CellExpansionButton.self) })
    }
    
    private func heightForSection(_ section: Int, _ tv: UITextView) -> CGFloat {
        tv.sizeThatFits(CGSize(width: (tableView?.frame.size.width ?? 32) - 32, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        howToUseAppViewModel().heightForRow(indexPath.row)
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
