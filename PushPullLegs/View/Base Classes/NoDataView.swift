//
//  NoDataView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class NoDataView: UIView {
    override func layoutSubviews() {
        addSubview(styledNoDataLabel(frame: bounds))
        backgroundColor = PPLColor.grey
    }
    
    func styledNoDataLabel(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : PPLColor.lightGrey!,
            NSAttributedString.Key.foregroundColor : PPLColor.darkGreyText!,
            NSAttributedString.Key.strokeWidth : -1.0,
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 72)
            ] as [NSAttributedString.Key : Any]
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString(string: "No Data", attributes: strokeTextAttributes)
        return label
    }
}
