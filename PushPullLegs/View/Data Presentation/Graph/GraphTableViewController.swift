//
//  GraphTableViewViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/7/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GraphTableViewController: UIViewController {
    
    weak var tableView: PPLTableView!
    var pushVc: GraphViewController!
    var pullVc: GraphViewController!
    var legsVc: GraphViewController!
    private var helpTag = 0
    private var interstitial: NSObject?
    private var selectedRow: Int!
    private weak var spinner: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
    }
    
    func adsRemoved() {
        if let tbv = tableView {
            tbv.removeFromSuperview()
            tableView = nil
        }
        removeBanner()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = PPLColor.backgroundBlue
        addBannerView(bannerAdUnitID())
        prepareTableView()
        prepareGraphViewControllers()
        navigationItem.titleView = titleLabel()
        constrainTableView()
        tableView.rowHeight = (tableView.frame.height) / 3
    }
    
    fileprivate func prepareTableView() {
        guard tableView == nil else {
            tableView.isUserInteractionEnabled = true
            tableView.reloadData()
            return
        }
        let height = view.frame.height - (tabBarController?.tabBar.frame.height ?? 0) - bannerHeight()
        let tbv = PPLTableView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: height))
        tbv.backgroundColor = PPLColor.clear
        view.addSubview(tbv)
        tbv.dataSource = self
        tbv.delegate = self
        tbv.separatorStyle = .none
        tableView = tbv
    }
    
    fileprivate func prepareGraphViewControllers() {
        guard pushVc == nil || pullVc == nil || legsVc == nil else {
            pushVc.view.setNeedsLayout()
            pullVc.view.setNeedsLayout()
            legsVc.view.setNeedsLayout()
            return
        }
        let frame = CGRect(x: 8, y: 8, width: view.frame.width - 16, height: tableView.rowHeight - 16)
        pushVc = GraphViewController(type: .push, frame: frame)
        pullVc = GraphViewController(type: .pull, frame: frame)
        legsVc = GraphViewController(type: .legs, frame: frame)
        pushVc.isInteractive = false
        pullVc.isInteractive = false
        legsVc.isInteractive = false
    }
    
    private func constrainTableView() {
        let guide = view.safeAreaLayoutGuide
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: guide.topAnchor, constant: bannerHeight()).isActive = true
        tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
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

}

extension GraphTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PPLTableViewCellIdentifier) as! PPLTableViewCell
        cell.tag = indexPath.row
        cell.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight)
        let view = viewForRow(indexPath.row)
        cell.rootView.addSubview(view)
        cell.contentView.clipsToBounds = false
        vcForRow(indexPath.row).viewModel.reload()
        if vcForRow(indexPath.row).viewModel.pointCount() > 0 {
            cell.addDisclosureIndicator()
        } else {
            cell.addHelpIndicator(target: self, action: #selector(help(_:)))
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
        lbl.textColor = PPLColor.darkGreyText
        vc.view.backgroundColor = PPLColor.offWhite
        lbl.sizeToFit()
        vc.view.addSubview(lbl)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.preferredContentSize = CGSize(width: lbl.frame.width + 10, height: lbl.frame.height + 10)
        lbl.frame = CGRect(x: lbl.frame.origin.x + 5, y: lbl.frame.origin.y + 5, width: lbl.frame.width, height: lbl.frame.height)
        helpTag = control.tag
        present(vc, animated: true, completion: nil)
    }
    
    func vcForRow(_ row: Int) -> GraphViewController {
        switch row {
        case 0:
            return pushVc
        case 1:
            return pullVc
        default:
            return legsVc
        }
    }
    
    func viewForRow(_ row: Int) -> UIView {
        vcForRow(row).view
    }
    
    @objc private func showGraph(_ row: Int) {
        guard let nav = navigationController else { return }
        let vc = GraphViewController(type: typeForRow(row))
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
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        navigateToGraphDetail()
    }
    
    private func navigateToGraphDetail() {
        if let spinner = spinner {
            spinner.removeFromSuperview()
        }
        interstitial = nil
        showGraph(selectedRow)
    }
    
    override func presentAdLoadingView() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: selectedRow, section: 0)) as? PPLTableViewCell else { return }
        let spinner = UIActivityIndicatorView(frame: cell.rootView.frame)
        spinner.layer.cornerRadius = cell.rootView.layer.cornerRadius
        spinner.style = .large
        spinner.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        cell.contentView.addSubview(spinner)
        spinner.startAnimating()
        self.spinner = spinner
    }
    
}

extension GraphTableViewController: UIPopoverPresentationControllerDelegate {
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .right
        guard let cell = tableView.cellForRow(at: IndexPath(row: helpTag, section: 0)) as? PPLTableViewCell else {
            return
        }
        popoverPresentationController.sourceView = cell.indicator
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension GraphTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        guard vcForRow(selectedRow).viewModel.pointCount() > 0 else { return }
        if !PPLDefaults.instance.wasGraphInterstitialShownToday(), let interstitial = createAndLoadInterstitial(adUnitID: InterstitialAdUnitID.graphTableVC) {
            PPLDefaults.instance.graphInterstitialWasJustShown()
            presentAdLoadingView()
            tableView.isUserInteractionEnabled = false
            interstitial.delegate = self
            self.interstitial = interstitial
        } else {
            showGraph(selectedRow)
        }
    }
}

extension UIViewController {
    func constrain(_ subview: UIView, toInsideOf superview: UIView, insets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 20
        , right: 8)) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
        subview.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
        subview.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right).isActive = true
    }
}
