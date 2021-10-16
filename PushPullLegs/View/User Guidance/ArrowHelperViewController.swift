//
//  ArrowHelperViewController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/29/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

@objc protocol ArrowHelperDataSource {
    func arrowCenterX() -> CGFloat
}

class ArrowHelperViewController: UIViewController {
    weak var arrowView: DownwardsArrowView!
    weak var dataSource: ArrowHelperDataSource?
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
        view.translatesAutoresizingMaskIntoConstraints = false
        addArrow()
        addLabel()
        positionView()
        prepareArrowAnimation()
        view.clipsToBounds = false
        view.heightAnchor.constraint(equalToConstant: VerticalArrowViewDimensions().height).isActive = true
    }
    
    func prepareArrowAnimation() {
        guard !animating else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {return}
            self.performArrowAnimation()
        }
        
    }
    
    fileprivate func performArrowAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.moveArrowUp()
        }) { (b) in
            UIView.animate(withDuration: 0.5, animations: {
                self.moveArrowDown()
            }) { (b) in
                self.prepareArrowAnimation()
            }
        }
    }
    
    fileprivate func moveArrowUp() {
        self.arrowView.frame.origin.y = self.arrowView.frame.origin.y - 30
    }
    
    fileprivate func moveArrowDown() {
        self.arrowView.frame.origin.y = self.arrowView.frame.origin.y + 30
    }
    
    fileprivate func addArrow() {
        guard arrowView == nil else { return }
        let dims = VerticalArrowViewDimensions()
        if let ds = dataSource {
            centerX_arrowView = ds.arrowCenterX()
        }
        let v = DownwardsArrowView(frame: CGRect(x: centerX_arrowView - dims.width / 2, y: 0, width: dims.width, height: dims.height))
        view.addSubview(v)
        arrowView = v
    }
    
    func repositionArrow() {
        let dims = VerticalArrowViewDimensions()
        arrowView.frame = CGRect(x: centerX_arrowView - dims.width / 2, y: 0, width: dims.width, height: dims.height)
    }
    
    fileprivate func addLabel() {
        guard !view.subviews.contains(where: { $0.isKind(of: UILabel.self) }) else { return }
        let dims = VerticalArrowViewDimensions()
        let lbl = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width - (dims.width + 20), height: dims.height)))
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
