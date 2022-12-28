//
//  GraphViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 5/27/21.
//  Copyright © 2021 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

class GraphViewController: UIViewController, ReloadProtocol, PPLDropdownViewControllerDelegate, PPLDropdownViewControllerDataSource, UIPopoverPresentationControllerDelegate {
    var viewModel: GraphViewModel?
    weak var containerView: UIView?
    weak var graphView: GraphView?
    weak var dateLabel: UILabel?
    weak var volumeLabel: UILabel?
    weak var titleLabel: UILabel?
    weak var labelStack: UIStackView?
    var firstLoad = true
    private var cancellables: Set<AnyCancellable> = []
    var padding: CGFloat { view.frame.width * 0.05 }
    var needConstraints = true
    var isInteractive = true
    private var heightForLabelStack: CGFloat { (isLandscape() ? 25 : 75) * ((volumeLabel != nil && dateLabel != nil) ? 2 : 1) }
    weak var dropdown: PPLDropDownViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isInteractive {
            letTabBarKnowGraphIsPresented(true)
        }
        view.backgroundColor = PPLColor.primary
        guard firstLoad else { return }
        setTitleLabel()
        firstLoad = false
        reloadViews()
        if isInteractive {
            bind()
            setupRightBarButtonItem()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        letTabBarKnowGraphIsPresented(false)
    }
    
    private func letTabBarKnowGraphIsPresented(_ presented: Bool) {
        if let tabBarController = tabBarController as? PPLTabBarController {
            tabBarController.isGraphPresented = presented
        }
    }
    
    func setTitleLabel() {
        let lbl = UILabel()
        lbl.text = viewModel?.title()
        lbl.font = titleLabelFont()
        navigationItem.titleView = lbl
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.reload()
            self.view.setNeedsLayout()
            self.view.setNeedsDisplay()
        })
        
    }
    
    private var windowInterfaceOrientation: UIInterfaceOrientation? {
        PPLSceneDelegate.shared?.window?.windowScene?.interfaceOrientation
    }
    
    func reload() {
        guard !firstLoad else { return }
        viewModel?.reload()
        reloadViews()
        view.backgroundColor = PPLColor.primary
    }
    
    func reloadViews() {
        containerView?.removeFromSuperview()
        graphView?.removeFromSuperview()
        labelStack?.removeFromSuperview()
        addContainerView()
        addLabels()
        addGraphView()
        bind()
    }
    
    func addContainerView() {
        let containerView = UIView(frame: view.frame)
        containerView.backgroundColor = PPLColor.primary
        view.addSubview(containerView)
        self.containerView = containerView
        addConstraints()
    }
    
    func addConstraints() {
        if needConstraints, let view = isInteractive ? containerView : self.view, let superview = view.superview {
            needConstraints = false
            view.translatesAutoresizingMaskIntoConstraints = false
            let insets = superview.safeAreaInsets
            if !isInteractive {
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top).isActive = true
                view.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom).isActive = true
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
            } else {
                let guide = view.safeAreaLayoutGuide
                view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
            }
        }
        addContainerConstraints()
    }
    
    func addContainerConstraints() {
        guard let containerView = containerView else { return }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
    }
    
    func addLabels() {
        guard let containerView = containerView else { return }
        var labels = [UILabel]()
        if !isInteractive {
            let titleLabel = getTitleLabel()
            labels.append(titleLabel)
            self.titleLabel = titleLabel
        } else {
            for lbl in [label(), label()] {
                labels.append(lbl)
                lbl.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: heightForLabelStack / 2)
            }
            dateLabel = labels[0]
            volumeLabel = labels[1]
        }
        let labelStack = UIStackView(arrangedSubviews: labels)
        containerView.addSubview(labelStack)
        self.labelStack = labelStack
        labelStack.isHidden = false
        labelStack.axis = .vertical
        labelStack.distribution = .fillEqually
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        labelStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        labelStack.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        labelStack.heightAnchor.constraint(equalToConstant: heightForLabelStack).isActive = true
    }
    
    private func getTitleLabel() -> UILabel {
        let lbl = label()
        lbl.text = viewModel?.title()
        lbl.sizeToFit()
        return lbl
    }
    
    func label() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        view.addSubview(label)
        label.numberOfLines = 1
        label.textColor = .white
        return label
    }
    
    func addGraphView() {
        let graph = GraphView(frame: CGRect(x: padding, y: 0, width: widthForGraphView(), height: heightForGraph()))
        graph.smallDisplay = !isInteractive
        containerView?.addSubview(graph)
        if isInteractive {
            graph.setInteractivity()
            containerView?.backgroundColor = .primary
        } else {
            graph.backgroundColor = .clear
        }
        containerView?.backgroundColor = .clear
        graph.translatesAutoresizingMaskIntoConstraints = false
        var topOffset: CGFloat = 0
        if let labelStack = labelStack {
            topOffset = (isInteractive ? 0 : labelStack.frame.height) + (isInteractive ? 0 : 8)
        }
        guard let containerView = containerView else { return }
        graph.topAnchor.constraint(equalTo: containerView.topAnchor, constant: topOffset).isActive = true
        graph.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: isInteractive ? 0 : -16).isActive = true
        graph.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        graph.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        graphView = graph
        graph.yValues = viewModel?.volumes()
        graph.circleLineY = heightForLabelStack - (isLandscape() ? 0 : 50)
    }
    
    private func widthForGraphView() -> CGFloat {
        (containerView?.frame.width ?? view.frame.width) - padding * 2
    }
    
    func heightForGraph() -> CGFloat {
        (containerView?.frame.height ?? view.frame.height) - padding
    }
    
    func bind() {
        cancellables.removeAll()
        graphView?.$index.sink { [weak self] index in
            guard let self = self else { return }
            self.updateLabels(index)
        }.store(in: &cancellables)
    }
    
    func updateLabels(_ index: Int?) {
        if let index = index, let date = viewModel?.dates()?[index], let volume = viewModel?.volumes()?[index] {
            dateLabel?.text = date
            volumeLabel?.text = "Volume: \(volume)".trimDecimalDigitsToTwo()
        } else {
            dateLabel?.text = nil
            volumeLabel?.text = nil
        }
        
    }
    
    func isLandscape() -> Bool {
        guard let orientation = windowInterfaceOrientation else { return false }
        return orientation == .landscapeLeft || orientation == .landscapeRight
    }
    
    override func viewDidLayoutSubviews() {
        viewModel?.reload()
        graphView?.yValues = viewModel?.volumes()
    }
    
    private func removeLabels() {
        labelStack?.removeAllSubviews()
    }
    
    func setupRightBarButtonItem() {
        guard let viewModel, viewModel.hasEllipsis else { return }
        let ellipsis = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: ellipsis, style: .plain, target: self, action: #selector(showDropdown(_:)))
    }
    
    @objc func showDropdown(_ sender: Any) {
        let vc = PPLDropDownViewController()
        vc.dataSource = self
        vc.delegate = self
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.containerView?.backgroundColor = PPLColor.clear
        vc.popoverPresentationController?.presentedView?.backgroundColor = PPLColor.clear
        present(vc, animated: true, completion: nil)
        dropdown = vc
    }
    
    func dropdownItems() -> [PPLDropdownItem] {
        []
    }
    
    func didSelectItem(_ item: PPLDropdownItem) {
        // no op
    }
    
    func didSelectDates(_ startDate: Date, _ endDate: Date) {
        viewModel?.refreshWithDates(startDate, endDate)
        reloadViews()
    }
    
    func dateNavigationItem() -> PPLDropdownDateNavigationItem? {
        if let date1 = viewModel?.startDate, let date2 = viewModel?.endDate, let minDate = viewModel?.earliestPossibleDate, let maxDate = viewModel?.lastPossibleDate {
            return PPLDropdownDateNavigationItem(firstDate: date1, secondDate: date2, minDate: minDate, maxDate: maxDate)
        }
        return nil
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .up
        guard let item = navigationItem.rightBarButtonItem else {
            return
        }
        popoverPresentationController.barButtonItem = item
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
    
    func showDateSelector() {
        let picker = UIDatePicker()
        let vc = UIViewController()
        vc.view.addSubview(picker)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.delegate = self
        present(vc, animated: true)
    }
}

extension UIView {
    func updateHeight(_ height: CGFloat) {
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: height))
    }
}
