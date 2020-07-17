//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import GoogleMobileAds
import UIKit

class PPLAdViewModel: NSObject {
    
}

class PPLTableView: UITableView {
    
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        guard let cell = super.dequeueReusableCell(withIdentifier: identifier) else { return nil }
        cell.backgroundColor = .clear
        cell.focusStyle = .custom
        cell.selectionStyle = .none
        return cell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = PPLColor.Grey
        separatorStyle = .none
    }
    
}

let PPLTableViewCellIdentifier = "PPLTableViewCellIdentifier"

class PPLTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var viewModel: ViewModel!
    weak var tableView: PPLTableView!
    weak var bannerView: GADBannerView!
    weak var noDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PPLColor.Grey
        addNoDataView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        hideBottomBar()
        addBannerView()
        addBackNavigationGesture()
    }
    
    fileprivate func hideBottomBar() {
        if let nvc = navigationController {
            hidesBottomBarWhenPushed = nvc.viewControllers[0] != self
        }
    }
    
    fileprivate func setupTableView() {
        setTableView()
        tableView.register(UINib(nibName: "PPLTableViewCell", bundle: nil), forCellReuseIdentifier: PPLTableViewCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        addTableFooter()
    }
    
    fileprivate func setTableView() {
        tableView = view.subviews.first(where: { $0.isKind(of: PPLTableView.self) }) as? PPLTableView
        if tableView == nil {
            let tableView = PPLTableView(frame: view.bounds)
            self.tableView = tableView
            view.addSubview(tableView)
        }
    }
    
    fileprivate func addTableFooter() {
        let footer = UIView(frame: .zero)
        footer.backgroundColor = tableView.backgroundColor
        tableView.tableFooterView = footer
    }
    
    fileprivate func addBackNavigationGesture() {
        if let grs = view.gestureRecognizers, grs.contains(where: { $0.isKind(of: UISwipeGestureRecognizer.self ) }) { return }
        if let vcs = navigationController?.viewControllers, vcs.count > 1 {
            let swipey = UISwipeGestureRecognizer(target: self, action: #selector(pop))
            swipey.direction = .right
            view.addGestureRecognizer(swipey)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let count = viewModel.sectionCount?() else {return}
        var isThereData = false
        for i in 0..<count {
            if viewModel.rowCount(section: i) > 0 {
                isThereData = true
                break
            }
        }
        noDataView.isHidden = isThereData
    }
    
    func addNoDataView() {
        let noDataView = UIView(frame: view.bounds)
        noDataView.addSubview(styledNoDataLabel(frame: view.bounds))
        view.addSubview(noDataView)
        self.noDataView = noDataView
        hideNoDataView()
    }
    
    func styledNoDataLabel(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : PPLColor.lightGrey!,
            NSAttributedString.Key.foregroundColor : PPLColor.darkGreyText!,
            NSAttributedString.Key.strokeWidth : -1.0,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 72)
            ] as [NSAttributedString.Key : Any]
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString(string: "No Data", attributes: strokeTextAttributes)
        return label
    }
    
    func showNoDataView() {
        noDataView.isHidden = false
    }
    
    func hideNoDataView() {
        noDataView.isHidden = true
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let bannerView = bannerView, view.subviews.contains(bannerView) {
            view.bringSubviewToFront(bannerView)
        }
        if let tbc = tabBarController, !hidesBottomBarWhenPushed && bannerView != nil {
            positionBannerView(yOffset: tbc.tabBar.frame.height)
        }
    }
    
    fileprivate func addBannerView() {
        guard AppState.shared.isAdEnabled else {
            return
        }
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        self.bannerView = bannerView
        positionBannerView()
    }
    
    func positionBannerView(yOffset: CGFloat = 0.0) {
        bannerView.frame = CGRect(x: (view.frame.width - bannerView.frame.width) / 2.0, y: view.frame.height - (bannerView.frame.height + yOffset), width: bannerView.frame.width, height: bannerView.frame.height)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let vm = viewModel, let count = vm.sectionCount?() else { return 1 }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel else { return 1 }
        return vm.rowCount(section: section)
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
            label.layer.backgroundColor = PPLColor.Grey?.cgColor
            label.textColor = UIColor.white
            headerView.addSubview(label)
            i += 1
        }
        headerView.layer.shadowRadius = 50
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 50, height: -50)
        return headerView
    }
}
