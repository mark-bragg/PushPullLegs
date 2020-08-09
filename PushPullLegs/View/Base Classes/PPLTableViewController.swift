//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import GoogleMobileAds
import UIKit

class PPLTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var viewModel: PPLTableViewModel!
    weak var tableView: PPLTableView!
    weak var bannerView: GADBannerView!
    weak var noDataView: NoDataView!
    weak var addButton: PPLAddButton!
    private let addButtonSize = CGSize(width: 75, height: 75)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        hideBottomBar()
        addBannerView()
        addBackNavigationGesture()
        view.backgroundColor = PPLColor.grey
        addNoDataView()
        tableView.reloadData()
    }
    
    @objc func addAction(_ sender: Any) {
        // no-op
    }
    
    fileprivate func hideBottomBar() {
        if let nvc = navigationController {
            hidesBottomBarWhenPushed = nvc.viewControllers[0] != self
        }
    }
    
    func setupAddButton() {
        attachAddButton()
        positionAddButton()
    }
    
    private func attachAddButton() {
        guard self.addButton == nil else {
            return
        }
        let button = PPLAddButton(frame: .zero)
        button.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        self.addButton = button
    }
    
    private func positionAddButton() {
        var y: CGFloat = -15
        if AppState.shared.isAdEnabled {
            y -= bannerView.frame.size.height
        }
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: addButtonSize.width).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: addButtonSize.height).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: y).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
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
            let tbl = PPLTableView()
            view.addSubview(tbl)
            tbl.translatesAutoresizingMaskIntoConstraints = false
            tbl.rowHeight = 75
            tbl.delegate = self
            tbl.dataSource = self
            tbl.reloadData()
            view.addSubview(tbl)
            tableView = tbl
            constrainToView(tableView)
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
        for i in 0..<count {
            if viewModel.rowCount(section: i) > 0 {
                hideNoDataView()
                return
            }
        }
        showNoDataView()
    }
    
    func addNoDataView() {
        guard noDataView == nil else {
            return
        }
        let ndv = NoDataView(frame: view.bounds)
        view.addSubview(ndv)
        ndv.isHidden = true
        noDataView = ndv
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
        return PPLTableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.setHighlighted(true, animated: true)
    }
    
    func tableHeaderView(titles: [String]) -> UIView {
        let headerHeight: CGFloat = 60.0
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: headerHeight)))
        var i = 0
        let widthDenominator = CGFloat(titles.count)
        let labelWidth = headerView.frame.width / widthDenominator
        let gradientTop = CAGradientLayer()
        gradientTop.frame = headerView.layer.bounds
        gradientTop.colors = [PPLColor.textBlue!.cgColor, PPLColor.grey!.cgColor, PPLColor.grey!.cgColor, PPLColor.textBlue!.cgColor, UIColor.clear.cgColor]
        gradientTop.locations = [0.0, 0.15, 0.85, 0.99, 1.0]
        headerView.layer.addSublayer(gradientTop)
        for title in titles {
            let label = UILabel.headerLabel(title)
            label.frame = CGRect(x: CGFloat(i) * labelWidth, y: 0, width: labelWidth, height: headerHeight)
            label.textColor = UIColor.white
            headerView.addSubview(label)
            i += 1
        }
        headerView.addShadow(.shadowOffsetTableHeader)
        return headerView
    }
}

class NoDataView: UIView {
    override func layoutSubviews() {
        addSubview(styledNoDataLabel(frame: bounds))
        backgroundColor = PPLColor.grey
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
}
