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
    private let tableViewTag = 1776
    var cancellables: Set<AnyCancellable> = []
    private var topConstraint: NSLayoutConstraint?
    
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
    
    func setupTableView() {
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
        topConstraint?.isActive = true
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let viewModel, let count = viewModel.sectionCount?() else { return }
        for i in 0..<count {
            if viewModel.rowCount(section: i) > 0 {
                hideNoDataView()
                return
            }
        }
        showNoDataView()
    }
    
    @objc func addAction() {
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
        let headerView = UIView(frame: CGRect(x: 0, y: 1, width: view.frame.width, height: headerHeight - 2))
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
    }
    
    func setupRightBarButtonItems() {
        navigationItem.rightBarButtonItem = nil
        let rightButtons = getRightBarButtonItems()
        if rightButtons.count > 2 {
            if let add = rightButtons.first(where: { $0.accessibilityIdentifier == .add }) {
                navigationItem.rightBarButtonItems = [add, dropdownBarButtonItem()]
            }
        } else {
            navigationItem.rightBarButtonItems = rightButtons
        }
    }
    
    func dropdownBarButtonItem() -> UIBarButtonItem {
        let ellipsisImage = UIImage(systemName: "ellipsis", variableValue: 1, configuration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.tintColor, renderingMode: .alwaysOriginal)
        let dropdown = UIBarButtonItem(image: ellipsisImage, style: .plain, target: self, action: #selector(showDropdown(_:)))
        return dropdown
    }
    
    @objc func showDropdown(_ sender: Any) {
        let vc = PPLDropDownViewController()
        vc.dataSource = self
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.containerView?.backgroundColor = PPLColor.clear
        vc.popoverPresentationController?.presentedView?.backgroundColor = PPLColor.clear
        present(vc, animated: true, completion: nil)
    }
    
    func getRightBarButtonItems() -> [UIBarButtonItem] {
        return []
    }
    
    func addButtonItem() -> UIBarButtonItem {
        let btn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        btn.accessibilityIdentifier = "Add"
        return btn
    }
}

extension PPLTableViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        guard let item = navigationItem.rightBarButtonItems?.first(where: { $0.accessibilityIdentifier != .add }) else {
            return
        }
        popoverPresentationController.barButtonItem = item
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}

extension PPLTableViewController: PPLDropdownViewControllerDataSource {
    func dropdownItems() -> [PPLDropdownItem] {
        let items = getRightBarButtonItems().filter { $0.accessibilityIdentifier != .add }
        var dropdownItems = [PPLDropdownItem]()
        for item in items {
            if let target = item.target, let action = item.action, let name = item.accessibilityIdentifier {
                dropdownItems.append(PPLDropdownItem(target: target, action: action, name: name))
            }
        }
        return dropdownItems
    }
}

extension PPLTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
}

extension PPLTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.sectionCount?() ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.rowCount(section: section) ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

extension PPLTableViewController: ReloadProtocol {
    @objc func reload() {
        if let viewModel, viewModel.hasData() {
            hideNoDataView()
            tableView?.reloadData()
            view.backgroundColor = PPLColor.primary
        } else {
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
