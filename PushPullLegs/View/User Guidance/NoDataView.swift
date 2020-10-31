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
    
    override func layoutSubviews() {
        addSubview(styledNoDataLabel(frame: bounds))
        backgroundColor = lightBackground ? PPLColor.grey : PPLColor.darkGrey
    }
    
    func styledNoDataLabel(frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: 72)
        label.textAlignment = .center
        label.text = "No Data"
        return label
    }
}
