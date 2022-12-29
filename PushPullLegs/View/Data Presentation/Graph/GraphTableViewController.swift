//
//  GraphTableViewViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class GraphTableViewController: PPLTableViewController {
    
    var pushVc: WorkoutGraphViewController?
    var pullVc: WorkoutGraphViewController?
    var legsVc: WorkoutGraphViewController?
    private var helpTag = 0
    private var interstitial: NSObject?
    private var selectedRow: Int?
    private weak var spinner: UIActivityIndicatorView?
    private var interstitialAd: STAStartAppAd?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
        tableView?.isScrollEnabled = false
    }
    
    override func reload() {
        for wgvc in [pushVc, pullVc, legsVc] {
            wgvc?.reload()
        }
    }
    
    override func adsRemoved() {
        if let tbv = tableView {
            tbv.removeFromSuperview()
            tableView = nil
        }
        removeBanner()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = PPLColor.primary
        if PPLDefaults.instance.isAdvertisingEnabled() {
            addBannerView()
        } else {
            removeBanner()
        }
        prepareTableView()
        prepareGraphViewControllers()
        navigationItem.titleView = titleLabel()
        constrainTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.frame.height / 3
    }
    
    fileprivate func prepareTableView() {
        guard tableView == nil else {
            tableView?.isUserInteractionEnabled = true
            tableView?.reloadData()
            return
        }
        let height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - bannerContainerHeight()
        let tbv = PPLTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height))
        tbv.backgroundColor = PPLColor.clear
        view.addSubview(tbv)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.separatorStyle = .none
        tbv.isScrollEnabled = false
        tableView = tbv
    }
    
    fileprivate func prepareGraphViewControllers() {
        if let pushVc, let pullVc, let legsVc {
            pushVc.view.setNeedsLayout()
            pullVc.view.setNeedsLayout()
            legsVc.view.setNeedsLayout()
            return
        }
        let frame = CGRect(x: 8, y: 8, width: view.frame.width - 16, height: (tableView?.rowHeight ?? view.frame.height / 3) - 16)
        pushVc = WorkoutGraphCellViewController(type: .push, frame: frame)
        pullVc = WorkoutGraphCellViewController(type: .pull, frame: frame)
        legsVc = WorkoutGraphCellViewController(type: .legs, frame: frame)
        for vc in [pushVc, pullVc, legsVc] {
            vc?.isInteractive = false
            vc?.view.backgroundColor = .clear
            vc?.view.subviews.forEach { $0.backgroundColor = .clear }
        }
    }
    
    private func constrainTableView() {
        let guide = view.safeAreaLayoutGuide
        tableView?.translatesAutoresizingMaskIntoConstraints = false
        tableView?.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView?.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        tableView?.topAnchor.constraint(equalTo: guide.topAnchor, constant: bannerContainerHeight()).isActive = true
        tableView?.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }
    
    func titleLabel() -> UILabel {
        let lbl = UILabel()
        lbl.text = "Trends"
        lbl.font = titleLabelFont()
        return lbl
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCellIdentifier),
            let view = viewForRow(indexPath.row)
        else { return UITableViewCell() }
        cell.tag = indexPath.row
        cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight)
        cell.contentView.addSubview(view)
        constrain(view, toInsideOf: cell.contentView)
        vcForRow(indexPath.row)?.reload()
        if let gVm = vcForRow(indexPath.row)?.workoutGraphViewModel, gVm.pointCount() > 0 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.addHelpIndicator(target: self, action: #selector(help(_:)))
            cell.selectionStyle = .none
        }
        if let tapView = cell.contentView.subviews.first(where: { $0.isKind(of: TapView.self) }) {
            tapView.removeFromSuperview()
        }
        let tapView = TapView(tag: indexPath.row + 1, target: self, action: #selector(tapViewTapped(_:)))
        cell.contentView.addSubview(tapView)
        constrain(tapView, toInsideOf: cell.contentView)
        return cell
    }
    
    @objc private func tapViewTapped(_ tap: UITapGestureRecognizer) {
        guard let tableView, let row = tap.view?.tag else { return }
        self.tableView(tableView, didSelectRowAt: IndexPath(row: row - 1, section: 0))
    }
    
    @objc func help(_ control: UIControl) {
        let vc = UIViewController()
        let lbl = UILabel()
        lbl.numberOfLines = 3
        lbl.text = "This graph has no data.\nStart working out,\nand build your graph!"
        lbl.textAlignment = .center
        lbl.textColor = PPLColor.pplDarkGrayText
        vc.view.backgroundColor = PPLColor.pplOffWhite
        lbl.sizeToFit()
        vc.view.addSubview(lbl)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: lbl.frame.width + 10, height: lbl.frame.height + 10)
        lbl.frame = CGRect(x: lbl.frame.origin.x + 5, y: lbl.frame.origin.y + 5, width: lbl.frame.width, height: lbl.frame.height)
        helpTag = control.tag
        present(vc, animated: true, completion: nil)
    }
    
    func viewForRow(_ row: Int) -> UIView? {
        vcForRow(row)?.view
    }
    
    func vcForRow(_ row: Int) -> WorkoutGraphViewController? {
        switch row {
        case 0:
            return pushVc
        case 1:
            return pullVc
        default:
            return legsVc
        }
    }
    
    @objc private func showGraph(_ row: Int) {
        guard let nav = navigationController else { return }
        let vc = WorkoutGraphViewController(type: typeForRow(row))
        vc.isInteractive = true
        vc.hidesBottomBarWhenPushed = true
        nav.show(vc, sender: self)
    }
    
    func typeForRow(_ row: Int) -> ExerciseType {
        switch row {
        case 0:
            return .push
        case 1:
            return .pull
        default:
            return .legs
        }
    }
    
    override func interstitialWillDismiss() {
        navigateToGraphDetail()
    }
    
    override func failedLoad(_ ad: STAAbstractAd!, withError error: Error!) {
        navigateToGraphDetail()
    }
    
    override func didClose(_ ad: STAAbstractAd!) {
        navigateToGraphDetail()
        PPLDefaults.instance.graphInterstitialWasJustShown()
    }
    
    private func navigateToGraphDetail() {
        if let spinner = spinner {
            spinner.removeFromSuperview()
        }
        interstitial = nil
        if let selectedRow {
            showGraph(selectedRow)
        }
    }
    
    override func presentAdLoadingView() {
        guard
            let selectedRow,
            let cell = tableView?.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? UITableViewCell
        else { return }
        let spinner = UIActivityIndicatorView(frame: cell.contentView.frame)
        spinner.layer.cornerRadius = cell.contentView.layer.cornerRadius
        spinner.style = .large
        spinner.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        cell.contentView.addSubview(spinner)
        spinner.startAnimating()
        self.spinner = spinner
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        guard
            let selectedRow,
            let gvm = vcForRow(selectedRow)?.workoutGraphViewModel, gvm.pointCount() > 0
        else { return }
        if PPLDefaults.instance.wasGraphInterstitialShownToday() {
            showGraph(selectedRow)
        } else {
            presentAdLoadingView()
            if let i = createAndLoadInterstitial() {
                interstitial = i
                tableView.isUserInteractionEnabled = false
            }
        }
    }
    
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension GraphTableViewController {
    override func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .right
        guard let cell = tableView?.cellForRow(at: IndexPath(row: helpTag, section: 0)) as? UITableViewCell else {
            return
        }
        popoverPresentationController.sourceView = cell.accessoryView
    }

    override func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension UIViewController {
    func constrain(_ subview: UIView, toInsideOf superview: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8
        , right: 8)) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
        subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
    }
}

extension UITableViewCell {
    func addHelpIndicator(target: AnyObject, action: Selector) {
        accessoryType = .detailButton
        accessoryView?.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
}

class TapView: UIView {
    init(tag: Int, target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        self.tag = tag
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
