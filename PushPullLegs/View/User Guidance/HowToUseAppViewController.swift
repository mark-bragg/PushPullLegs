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
    private let reuseId = "reuseId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = HowToUseAppViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard firstLoad else { return }
        firstLoad = false
        tableView?.showsVerticalScrollIndicator = true
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: reuseId)
    }
    
    override func addBannerView(size: STABannerSize) {
        // no op
    }
    
    override func bannerContainerHeight(size: STABannerSize) -> CGFloat {
        0
    }
    
    var howToUseAppViewModel: HowToUseAppViewModel? {
        viewModel as? HowToUseAppViewModel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        howToUseAppViewModel?.sectionCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        howToUseAppViewModel?.titleForSection(section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
        cell.contentView.backgroundColor = PPLColor.primary
        addTextView(to: cell, at: indexPath)
        return cell
    }
    
    private func addTextView(to cell: UITableViewCell, at indexPath: IndexPath) {
        let tv = cell.contentView.subviews.first { $0.isKind(of: UITextView.self) } as? UITextView ?? getNewTextView(at: indexPath)
        tv.text = howToUseAppViewModel?.title(indexPath: indexPath)
        howToUseAppViewModel?.setHeight(heightForTextView(tv), forSection: indexPath.section)
        tv.frame = CGRect(x: 16, y: 0, width: cell.contentView.frame.width - 16, height: heightForRow(at: indexPath))
        cell.contentView.addSubview(tv)
    }
    
    private func getNewTextView(at indexPath: IndexPath) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.font = UIFont.systemFont(ofSize: 20)
        return tv
    }
    
    private func heightForTextView(_ tv: UITextView) -> CGFloat {
        tv.sizeThatFits(CGSize(width: (tableView?.frame.size.width ?? 32) - 32, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightForRow(at: indexPath)
    }
    
    private func heightForRow(at indexPath: IndexPath) -> CGFloat {
        howToUseAppViewModel?.heightForRow(indexPath.section) ?? 0
    }

}
