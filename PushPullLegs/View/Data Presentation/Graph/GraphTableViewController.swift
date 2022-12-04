//
//  GraphTableViewViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class GraphTableViewController: PPLTableViewController {
    
    var pushVc: WorkoutGraphViewController!
    var pullVc: WorkoutGraphViewController!
    var legsVc: WorkoutGraphViewController!
    private var helpTag = 0
    private var interstitial: NSObject?
    private var selectedRow: Int!
    private weak var spinner: UIActivityIndicatorView!
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
        guard pushVc == nil || pullVc == nil || legsVc == nil else {
            pushVc.view.setNeedsLayout()
            pullVc.view.setNeedsLayout()
            legsVc.view.setNeedsLayout()
            return
        }
        let frame = CGRect(x: 8, y: 8, width: view.frame.width - 16, height: (tableView?.rowHeight ?? view.frame.height / 3) - 16)
        pushVc = WorkoutGraphViewController(type: .push, frame: frame)
        pullVc = WorkoutGraphViewController(type: .pull, frame: frame)
        legsVc = WorkoutGraphViewController(type: .legs, frame: frame)
        pushVc.isInteractive = false
        pullVc.isInteractive = false
        legsVc.isInteractive = false
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
    
    @objc override func bannerAdUnitID() -> String {
        BannerAdUnitID.graphTableVC
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        guard let rootView = cell.rootView else { return cell }
        cell.tag = indexPath.row
        cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight)
        let view = viewForRow(indexPath.row)
        rootView.addSubview(view)
        constrain(view, toInsideOf: rootView)
        vcForRow(indexPath.row).reload()
        if vcForRow(indexPath.row).workoutGraphViewModel.pointCount() > 0 {
            cell.addDisclosureIndicator(PPLColor.white)
        } else {
            cell.addHelpIndicator(target: self, action: #selector(help(_:)), color: .white)
            cell.selectionStyle = .none
        }
        return cell
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
    
    func viewForRow(_ row: Int) -> UIView {
        vcForRow(row).view
    }
    
    func vcForRow(_ row: Int) -> WorkoutGraphViewController {
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
        showGraph(selectedRow)
    }
    
    override func presentAdLoadingView() {
        guard
            let cell = tableView?.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? PPLTableViewCell,
                let rootView = cell.rootView
        else { return }
        let spinner = UIActivityIndicatorView(frame: rootView.frame)
        spinner.layer.cornerRadius = rootView.layer.cornerRadius
        spinner.style = .large
        spinner.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        cell.contentView.addSubview(spinner)
        spinner.startAnimating()
        self.spinner = spinner
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        guard vcForRow(selectedRow).workoutGraphViewModel.pointCount() > 0 else { return }
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

extension GraphTableViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .right
        guard let cell = tableView?.cellForRow(at: IndexPath(row: helpTag, section: 0)) as? PPLTableViewCell else {
            return
        }
        popoverPresentationController.sourceView = cell.indicator
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
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
