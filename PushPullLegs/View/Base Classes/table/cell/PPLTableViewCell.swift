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

    static var borderWidth: CGFloat = 6
    @IBOutlet weak var rootView: ShadowBackground!
    var pplSelectionFlag = false
    weak var indicator: UIView?
    var multiSelect: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.isUserInteractionEnabled = false
        rootView.backgroundColor = .cellBackgroundBlue
    }
    
    static func nib() -> UINib {
        UINib(nibName: "PPLTableViewCell", bundle: nil)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard !multiSelect && selectionStyle != .none else { return }
        if highlighted {
            rootView.removeShadow()
        } else {
            addShadowAnimated()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        guard multiSelect && animated else { return }
        rootView.isSelected = selected
        if selected {
            rootView.removeShadow()
        } else if animated {
            rootView.addShadow(.shadowOffsetCell)
        }
    }
    
    private func addShadowAnimated() {
        UIView.animate(withDuration: 1.0) { [weak self] in
            guard let self = self else { return }
            self.rootView.addShadow(.shadowOffsetCell)
        }
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
        super.init(image: UIImage(systemName: "questionmark.circle")?.withTintColor(PPLColor.backgroundBlue!, renderingMode: .alwaysOriginal))
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
    static let shadowOffset = CGSize(width: 0, height: 5)
    static let shadowOffsetCell = CGSize(width: 0, height: 17)
    static let shadowOffsetAddButton = CGSize(width: 0, height: 8)
    static let shadowOffsetTableHeader = CGSize(width: 0, height: 17)
}

extension UIView {
    func addShadow(_ offset: CGSize = .shadowOffset, _ animated: Bool = true) {
        removeShadow()
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.shadowPath = CGPath(rect: CGRect(x: 2.5, y: 0, width: bounds.width - 5, height: bounds.height), transform: nil)
        layer.shadowOffset = offset
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1.0
    }
    
    func removeShadow() {
        self.layer.shadowPath = nil
        self.layer.shadowOffset = .zero
        layer.shadowOpacity = .zero
    }
}

class ShadowBackground: UIView {
    var isSelected = false
    override func layoutSubviews() {
        if !isSelected {
            addShadow(.shadowOffsetCell)
        }
        layer.borderWidth = PPLTableViewCell.borderWidth
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = layer.bounds.height * 0.03
    }
}
