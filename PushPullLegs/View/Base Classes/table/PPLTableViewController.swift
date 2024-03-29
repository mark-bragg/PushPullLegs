//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class PPLTableViewController: UIViewController, AdsRemovedResponder {
    
    var viewModel: PPLTableViewModel?
    weak var tableView: PPLTableView?
    weak var noDataView: NoDataView?
    weak var addButton: PPLAddButton!
    let addButtonSize = CGSize(width: 75, height: 75)
    weak var addButtonHelperVc: ArrowHelperViewController?
    private let tableViewTag = 1776
    private let headerTag = 1984
    var headerView: UIView? {
        return view.viewWithTag(headerTag)
    }
    var cancellables: Set<AnyCancellable> = []
    private var topConstraint: NSLayoutConstraint!
    
    // MARK: view lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    func adsRemoved() {
        if let tbv = tableView {
            tbv.removeFromSuperview()
            tableView = nil
        }
        if let ndv = noDataView {
            ndv.removeFromSuperview()
            noDataView = nil
        }
        if let btn = addButton {
            btn.removeFromSuperview()
            addButton = nil
        }
        removeBanner()
        setupViews()
    }
    
    private func setupViews() {
        addBannerView()
        setupTableView()
        hideBottomBar()
        addBackNavigationGesture()
        view.backgroundColor = PPLColor.primary
        addNoDataView()
        tableView?.reloadData()
        setTitle()
    }
    
    fileprivate func setupTableView() {
        setTableView()
        constrainTableView()
        addTableFooter()
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    fileprivate func setTableView() {
        tableView = view.viewWithTag(tableViewTag) as? PPLTableView
        guard tableView == nil else { return }
        let tbl = PPLTableView()
        tbl.tag = tableViewTag
        view.addSubview(tbl)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        tbl.rowHeight = 75
        tbl.reloadData()
        tableView = tbl
    }
    
    private func constrainTableView() {
        let guide = view.safeAreaLayoutGuide
        guard let tableView = tableView else { return }
        tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        setTableViewY(bannerContainerHeight())
        let bottom = tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
        bottom.identifier = "bottom"
        bottom.isActive = true
    }
    
    func setTableViewY(_ y: CGFloat) {
        topConstraint = tableView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: y)
        topConstraint.isActive = true
    }
    
    fileprivate func addTableFooter() {
        let footer = UIView(frame: .zero)
        footer.backgroundColor = tableView?.backgroundColor
        tableView?.tableFooterView = footer
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
        if addButton != nil, let vm = viewModel, !vm.hasData() {
            insertAddButtonInstructions()
        }
    }
    
    func insertAddButtonInstructions(_ dataSource: ArrowHelperDataSource? = nil) {
        guard let addButton = addButton else { return }
        if addButtonHelperVc != nil {
            removeAddButtonInstructions()
        }
        let addButtonHelperVc = ArrowHelperViewController()
        addButtonHelperVc.dataSource = dataSource
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
        guard let vm = viewModel, let count = vm.sectionCount?() else { return }
        for i in 0..<count {
            if vm.rowCount(section: i) > 0 {
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
        showNoDataView()
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
    
    func positionAddButton() {
        let y: CGFloat = -15
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.widthAnchor.constraint(equalToConstant: addButtonSize.width).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: addButtonSize.height).isActive = true
        addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: y).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: y).isActive = true
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
        if let vm = viewModel, let ndt = vm.noDataText?() {
            ndv.text = ndt
        }
        noDataView = ndv
        view.bringSubviewToFront(bannerContainerView(0))
    }
    
    func showNoDataView() {
        noDataView?.isHidden = false
    }
    
    func hideNoDataView() {
        noDataView?.isHidden = true
    }
    
    func tableHeaderViewContainer(titles: [String], section: Int = 0) -> HeaderViewContainer {
        let headerHeight: CGFloat = tableView(tableView ?? UITableView(), heightForHeaderInSection: section)
        if headerHeight == 0 {
            return HeaderViewContainer(frame: .zero)
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
        var i = 0
        let widthDenominator = CGFloat(titles.count)
        let labelWidth = headerView.frame.width / widthDenominator
        headerView.backgroundColor = .tertiary
        for title in titles {
            let label = UILabel.headerLabel(title)
            label.frame = CGRect(x: CGFloat(i) * labelWidth, y: 0, width: labelWidth, height: headerHeight)
            headerView.addSubview(label)
            i += 1
        }
        let headerViewContainer = HeaderViewContainer(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerHeight))
        headerViewContainer.headerView = headerView
        return headerViewContainer
    }
    
    func removeAddButton() {
        hideNoDataView()
        self.addButton.removeTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        self.addButton.removeFromSuperview()
    }
}

extension PPLTableViewController: UITableViewDelegate {
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

extension PPLTableViewController: ReloadProtocol {
    @objc func reload() {
        if let vm = viewModel, vm.hasData() {
            if let btn = addButton, btn.superview == view {
                removeAddButtonInstructions()
            }
            hideNoDataView()
            tableView?.reloadData()
            view.backgroundColor = PPLColor.primary
        } else {
            insertAddButtonInstructions()
            showNoDataView()
        }
    }
}

extension UIViewController {
    func titleLabelFont() -> UIFont {
        UIFont.systemFont(ofSize: 32, weight: .heavy)
    }
}

extension UILabel {
    static func headerLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }
}

protocol AdsRemovedResponder {
    func adsRemoved()
}
