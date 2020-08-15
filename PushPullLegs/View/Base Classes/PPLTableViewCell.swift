//
//  PPLTableViewCell.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 7/12/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let PPLTableViewCellIdentifier = "PPLTableViewCellIdentifier"

class PPLTableViewCell: UITableViewCell {

    @IBOutlet weak var rootView: ShadowBackground!
    var pplSelectionFlag = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rootView.isUserInteractionEnabled = false
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard selectionStyle != .none else { return }
        if highlighted {
            self.rootView.removeShadow()
        } else {
            self.rootView.addShadow()
            self.rootView.layer.borderColor = UIColor.white.cgColor
            self.rootView.layer.borderWidth = 4
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.05, animations: {
            if !selected {
                self.rootView.addShadow()
                self.rootView.layer.borderColor = UIColor.white.cgColor
                self.rootView.layer.borderWidth = 4
            }
        })
    }
    
    func addDisclosureIndicator() {
        let indicator = UIImage.init(systemName: "chevron.right")!
        let indicatorView = UIImageView(image: indicator.withTintColor(PPLColor.lightGrey!, renderingMode: .alwaysOriginal))
        rootView.addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor, constant: -20).isActive = true
        indicatorView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor).isActive = true
    }
    
}

extension CGSize {
    static var shadowOffset = CGSize(width: -5, height: 5)
    static var shadowOffsetAddButton = CGSize(width: -10, height: 10)
    static var shadowOffsetTableHeader = CGSize(width: -7, height: 7)
}

extension UIView {
    func addShadow(_ offset: CGSize = .shadowOffset) {
        removeShadow()
        layer.shadowOffset = .shadowOffset
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
        layer.shadowOffset = .shadowOffset
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = layer.bounds.height/8
    }
}
