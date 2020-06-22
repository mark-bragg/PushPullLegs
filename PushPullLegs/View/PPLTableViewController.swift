//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class PPLTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: ViewModel!
    
    override
    func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let count = viewModel.sectionCount?() else { return 1 }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowCount(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableHeaderView(titles: [String]) -> UIView {
        let headerHeight: CGFloat = 60.0
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: headerHeight)))
        var i = 0
        let widthDenominator = CGFloat(titles.count)
        let labelWidth = headerView.frame.width / widthDenominator
        for title in titles {
            let label = UILabel.headerLabel(title)
            label.frame = CGRect(x: CGFloat(i) * labelWidth, y: 0, width: labelWidth, height: headerHeight)
            label.layer.borderColor = UIColor.darkGray.cgColor
            label.layer.borderWidth = 2.0
            label.backgroundColor = .systemBackground
            label.textColor = .systemBlue
            headerView.addSubview(label)
            i += 1
        }
        return headerView
    }
}
