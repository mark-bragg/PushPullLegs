//
//  PPLTableViewCell.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import Combine

let PPLTableViewCellIdentifier = "PPLTableViewCellIdentifier"

class PPLTableViewCell: UITableViewCell {

    @IBOutlet weak var rootView: ShadowBackground!
    var pplSelectionFlag = false
    weak var indicator: UIView?
    var autoDeselect = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.isUserInteractionEnabled = false
    }
    
    static func nib() -> UINib {
        UINib(nibName: "PPLTableViewCell", bundle: nil)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard selectionStyle != .none else { return }
        if highlighted {
            self.rootView.removeShadow()
            if autoDeselect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    self.rootView.addShadow(.shadowOffsetCell)
                }
            }
        } else {
            self.rootView.addShadow(.shadowOffsetCell)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.05, animations: {
            if !selected {
                self.rootView.addShadow(.shadowOffsetCell)
                self.rootView.layer.borderColor = UIColor.white.cgColor
                self.rootView.layer.borderWidth = 4
            }
        })
    }
    
    func addDisclosureIndicator() {
        removeIndicator()
        let indicator = UIImage.init(systemName: "chevron.right")!
        let indicatorView = UIImageView(image: indicator.withTintColor(PPLColor.lightGrey!, renderingMode: .alwaysOriginal))
        rootView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
        self.indicator = indicatorView
    }
    
    func addHelpIndicator(target: Any?, action: Selector) {
        removeIndicator()
        let indicatorView = QuestionMarkView()
        indicatorView.tag = tag
        indicatorView.add(target: target, action: action)
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.indicator = indicatorView
    }
    
    func removeIndicator() {
        guard let indicator = indicator else { return }
        indicator.removeFromSuperview()
        self.indicator = nil
    }
    
}

class QuestionMarkView: UIImageView {
    init() {
        super.init(image: UIImage(systemName: "questionmark.circle")?.withTintColor(PPLColor.textBlue!, renderingMode: .alwaysOriginal))
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func add(target: Any?, action: Selector) {
        let indicatorControl = UIControl(frame: bounds)
        indicatorControl.isUserInteractionEnabled = true
        indicatorControl.tag = tag
        addSubview(indicatorControl)
        indicatorControl.addTarget(target, action: action, for: .touchUpInside)
    }
}

extension CGSize {
    static var shadowOffset = CGSize(width: -5, height: 5)
    static var shadowOffsetCell = CGSize(width: -7, height: 15)
    static var shadowOffsetAddButton = CGSize(width: -8, height: 8)
    static var shadowOffsetTableHeader = CGSize(width: -7, height: 7)
}

extension UIView {
    func addShadow(_ offset: CGSize = .shadowOffset) {
        removeShadow()
        layer.shadowOffset = offset
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.75
        
    }
    
    func removeShadow() {
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.0
    }
}

class ShadowBackground: UIView {
    var isSelected = false
    override func layoutSubviews() {
        layer.shadowPath = UIBezierPath.init(roundedRect: bounds, cornerRadius: bounds.size.height / 8).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.75
        layer.shadowOffset = .shadowOffsetCell
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = layer.bounds.height/8
    }
}