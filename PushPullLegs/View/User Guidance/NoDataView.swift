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
    
    override func layoutSubviews() {
        if label() == nil {
            addSubview(styledNoDataLabel(frame: bounds))
        }
        backgroundColor = lightBackground ? PPLColor.backgroundBlue : PPLColor.darkGrey
    }
    
    func styledNoDataLabel(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: 72)
        label.textAlignment = .center
        label.text = "No Data"
        return label
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
//        let leftBar = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: frame.height))
//        let bottomBar = UIView(frame: CGRect(x: 0, y: frame.height - 5, width: frame.width, height: 5))
//        leftBar.backgroundColor = .backgroundBlue
//        bottomBar.backgroundColor = .backgroundBlue
//        addSubviews([leftBar, bottomBar])
    }
}

extension UIView {
    func addSubviews(_ views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }
}
