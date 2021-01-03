//
//  NoDataView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class NoDataView: UIView {
    var lightBackground: Bool = true
    let labelTag = 1234
    var text = "No Data" {
        willSet {
            updateLabel(newValue)
        }
    }
    
    func updateLabel(_ text: String) {
        guard let label = label() else {return}
        label.text = text
        let height = label.textRect(forBounds: bounds, limitedToNumberOfLines: 10).height
        label.heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
    }
    
    override func layoutSubviews() {
        if label() == nil {
            addSubview(styledNoDataLabel(frame: bounds))
            positionLabel()
        }
        backgroundColor = lightBackground ? PPLColor.backgroundBlue : PPLColor.darkGrey
    }
    
    func styledNoDataLabel(frame: CGRect) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 72)
        label.textAlignment = .center
        label.text = text
        label.sizeToFit()
        label.tag = labelTag
        label.numberOfLines = 0
        return label
    }
    
    func positionLabel() {
        guard let label = label() else {return}
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
    }
    
    func label() -> UILabel? {
        return viewWithTag(labelTag) as? UILabel
    }
}

class NoDataGraphView: NoDataView {
    var whiteBackground = false
    override func layoutSubviews() {
        lightBackground = true
        super.layoutSubviews()
        if whiteBackground {
            backgroundColor = .cellBackgroundBlue
        }
    }
}

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}
