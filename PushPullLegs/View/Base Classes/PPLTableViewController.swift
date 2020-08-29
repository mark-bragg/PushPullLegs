//
//  PPLTableViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 6/20/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import GoogleMobileAds
import UIKit

class ArrowHelperViewController: UIViewController {
    weak var arrowView: ArrowView!
    var message: String = "Tap to create new exercises!" {
        didSet {
            redrawText()
        }
    }
    let fontSize: CGFloat = 28
    var centerX_arrowView: CGFloat = 0 {
        didSet {
            guard arrowView != nil else { return }
            self.repositionArrow()
        }
    }
    var bottomY: CGFloat = 0
    var animating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addArrow()
        addLabel()
        positionView()
        animateArrow()
        view.clipsToBounds = false
    }
    
    func animateArrow() {
        guard !animating else { return }
        weak var weakSelf = self
        DispatchQueue.main.async {
            guard let weakSelf = weakSelf else {return}
            UIView.animate(withDuration: 0.5, animations: {
                weakSelf.arrowView.frame.origin.y = weakSelf.arrowView.frame.origin.y - 30
            }) { (b) in
                UIView.animate(withDuration: 0.5, animations: {
                    weakSelf.arrowView.frame.origin.y = weakSelf.arrowView.frame.origin.y + 30
                }) { (b) in
                    weakSelf.animateArrow()
                }
            }
        }
        
    }
    
    fileprivate func addArrow() {
        guard arrowView == nil else { return }
        let v = ArrowView(frame: CGRect(x: centerX_arrowView - ArrowView.width / 2, y: 0, width: ArrowView.width, height: ArrowView.height))
        view.addSubview(v)
        arrowView = v
    }
    
    func repositionArrow() {
        arrowView.frame = CGRect(x: centerX_arrowView - ArrowView.width / 2, y: 0, width: ArrowView.width, height: ArrowView.height)
    }
    
    fileprivate func addLabel() {
        guard !view.subviews.contains(where: { $0.isKind(of: UILabel.self) }) else { return }
        let lbl = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width - (ArrowView.width + 20), height: ArrowView.height)))
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        lbl.text = message
        lbl.numberOfLines = 0
        view.addSubview(lbl)
    }
    
    func positionView() {
        view.frame = CGRect(x: 0, y: bottomY - view.frame.height, width: view.frame.width, height: view.frame.height)
    }
    
    func redrawText() {
        guard let lbl = view.subviews.first(where: { $0.isKind(of: UILabel.self) }) as? UILabel else { return }
        lbl.text = message
    }
}

class PPLTableViewController: UIViewController {
    
    var viewModel: PPLTableViewModel!
    weak var tableView: PPLTableView!
    weak var bannerView: GADBannerView!
    weak var noDataView: NoDataView!
    weak var addButton: PPLAddButton!
    private let addButtonSize = CGSize(width: 75, height: 75)
    weak var addButtonHelperVc: ArrowHelperViewController?
    
    // MARK: view lifecycle
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
        if addButtonHelperVc.view.superview == nil {
            view.addSubview(addButtonHelperVc.view)
        }
        addButtonHelperVc.didMove(toParent: self)
        addButtonHelperVc.view.frame = CGRect(x: 0, y: addButton.frame.origin.y - ArrowView.height, width: view.frame.width, height: ArrowView.height)
        self.addButtonHelperVc = addButtonHelperVc
    }
    
    func removeAddButtonInstructions() {
        guard let addButtonHelperVc = addButtonHelperVc else { return }
        addButtonHelperVc.willMove(toParent: nil)
        addButtonHelperVc.view.removeFromSuperview()
        addButtonHelperVc.removeFromParent()
        self.addButtonHelperVc = nil
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
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: y).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }
    
    fileprivate func setupTableView() {
        setTableView()
        tableView.register(UINib(nibName: "PPLTableViewCell", bundle: nil), forCellReuseIdentifier: PPLTableViewCellIdentifier)
        addTableFooter()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    fileprivate func setTableView() {
        tableView = view.subviews.first(where: { $0.isKind(of: PPLTableView.self) }) as? PPLTableView
        if tableView == nil {
            let tbl = PPLTableView()
            view.addSubview(tbl)
            tbl.translatesAutoresizingMaskIntoConstraints = false
            tbl.rowHeight = 75
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
}

extension PPLTableViewController: ReloadProtocol {
    @objc func reload() {
        if viewModel.hasData(), let btn = addButton, btn.superview == view {
            removeAddButtonInstructions()
            hideNoDataView()
            tableView.reloadData()
        } else {
            insertAddButtonInstructions()
            showNoDataView()
        }
    }
}
