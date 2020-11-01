//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import GoogleMobileAds
import UIKit
import Combine

class PPLTableViewController: UIViewController {
    
    var viewModel: PPLTableViewModel!
    weak var tableView: PPLTableView!
    weak var bannerView: GADBannerView!
    weak var noDataView: NoDataView!
    weak var addButton: PPLAddButton!
    private let addButtonSize = CGSize(width: 75, height: 75)
    weak var addButtonHelperVc: ArrowHelperViewController?
    private let tableViewTag = 1776
    private let headerTag = 1984
    var headerView: UIView? {
        return view.viewWithTag(headerTag)
    }
    var cancellables: Set<AnyCancellable> = []
    var hasBannerView = true
    
    // MARK: view lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        hideBottomBar()
        if hasBannerView {
            addBannerView()
        }
        addBackNavigationGesture()
        view.backgroundColor = PPLColor.grey
        addNoDataView()
        tableView.reloadData()
        setTitle()
    }
    
    fileprivate func setupTableView() {
        setTableView()
        addTableFooter()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    fileprivate func setTableView() {
        tableView = view.viewWithTag(tableViewTag) as? PPLTableView
        if tableView == nil {
            let tbl = PPLTableView()
            tbl.tag = tableViewTag
            view.addSubview(tbl)
            tbl.translatesAutoresizingMaskIntoConstraints = false
            tbl.rowHeight = 75
            tbl.reloadData()
            tableView = tbl
            constrainTableView()
        }
    }
    
    private func constrainTableView() {
        let guide = view.safeAreaLayoutGuide
        guard let tableView = tableView else { return }
        tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }
    
    fileprivate func addTableFooter() {
        let footer = UIView(frame: .zero)
        footer.backgroundColor = tableView.backgroundColor
        tableView.tableFooterView = footer
    }
    
    private func setTitle() {
        let lbl = titleLabel()
        navigationItem.titleView = lbl
        navigationItem.title = lbl.text
    }
    
    private func titleLabel() -> UILabel {
        let lbl = UILabel()
        guard let viewModel = viewModel, let title = viewModel.title?() else {
            return lbl
        }
        lbl.text = title
        lbl.font = titleLabelFont()
        lbl.sizeToFit()
        return lbl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let bannerView = bannerView, view.subviews.contains(bannerView) {
            view.bringSubviewToFront(bannerView)
        }
        if let tbc = tabBarController, !hidesBottomBarWhenPushed && bannerView != nil {
            positionBannerView(yOffset: tbc.tabBar.frame.height)
        }
        if addButton != nil && !viewModel.hasData() {
            insertAddButtonInstructions()
        }
    }
    
    func insertAddButtonInstructions() {
        guard let addButton = addButton else { return }
        if addButtonHelperVc != nil {
            removeAddButtonInstructions()
        }
        let addButtonHelperVc = ArrowHelperViewController()
        addButtonHelperVc.bottomY = addButton.frame.origin.y
        addButtonHelperVc.centerX_arrowView = addButton.center.x
        addChild(addButtonHelperVc)
        self.addButtonHelperVc = addButtonHelperVc
        if addButtonHelperVc.view.superview == nil {
            view.addSubview(addButtonHelperVc.view)
            activateAddHelperConstraints(true)
        }
        addButtonHelperVc.didMove(toParent: self)
    }
    
    func removeAddButtonInstructions() {
        guard let addButtonHelperVc = addButtonHelperVc else { return }
        addButtonHelperVc.willMove(toParent: nil)
        activateAddHelperConstraints(false)
        addButtonHelperVc.view.removeFromSuperview()
        addButtonHelperVc.removeFromParent()
        self.addButtonHelperVc = nil
    }
    
    func activateAddHelperConstraints(_ activation: Bool) {
        guard let addButtonHelperVc = addButtonHelperVc else { return }
        addButtonHelperVc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = activation
        addButtonHelperVc.view.bottomAnchor.constraint(equalTo: addButton.topAnchor).isActive = activation
        addButtonHelperVc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = activation
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
    
    @objc func addAction(_ sender: Any) {
        // no-op
    }
    
    @objc func pop() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: subview manipulation
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
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: y).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        view.bringSubviewToFront(addButton)
    }
    
    fileprivate func addBackNavigationGesture() {
        if let grs = view.gestureRecognizers, grs.contains(where: { $0.isKind(of: UISwipeGestureRecognizer.self ) }) { return }
        if let vcs = navigationController?.viewControllers, vcs.count > 1 {
            let swipey = UISwipeGestureRecognizer(target: self, action: #selector(pop))
            swipey.direction = .right
            view.addGestureRecognizer(swipey)
        }
    }
    
    func addNoDataView() {
        while view.subviews.contains(where: { $0.isKind(of: NoDataView.self) }) {
            view.subviews.first(where: { $0.isKind(of: NoDataView.self) })!.removeFromSuperview()
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

extension PPLTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.setHighlighted(true, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
}

extension PPLTableViewController: UITableViewDataSource {
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
}

extension PPLTableViewController: GADBannerViewDelegate {
    fileprivate func addBannerView() {
        guard AppState.shared.isAdEnabled else {
            return
        }
        while view.subviews.contains(where: { $0.isKind(of: GADBannerView.self) }) {
            view.subviews.first(where: { $0.isKind(of: GADBannerView.self) })!.removeFromSuperview()
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
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bannerView.widthAnchor.constraint(equalToConstant: bannerView.frame.width).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: bannerView.frame.height).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//
//        bannerView.frame = CGRect(x: (view.frame.width - bannerView.frame.width) / 2.0, y: view.frame.height - (bannerView.frame.height + totalOffset(yOffset)), width: bannerView.frame.width, height: bannerView.frame.height)
    }
    
    func totalOffset(_ offset: CGFloat) -> CGFloat {
        return offset + (hidesBottomBarWhenPushed ? view.safeAreaInsets.bottom : 0)
    }
}

extension PPLTableViewController: ReloadProtocol {
    @objc func reload() {
        if viewModel.hasData() {
            if let btn = addButton, btn.superview == view {
                removeAddButtonInstructions()
            }
            hideNoDataView()
            tableView.reloadData()
        } else {
            insertAddButtonInstructions()
            showNoDataView()
        }
    }
}

extension UIViewController {
    func titleLabelFont() -> UIFont {
        UIFont.systemFont(ofSize: 36, weight: .heavy)
    }
}
