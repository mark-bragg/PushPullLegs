//
//  NoDataView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

class NoDataView: UIView {
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(named: "AppIconBlack")
        addSubview(imgV)
        imgV.translatesAutoresizingMaskIntoConstraints = false
        imgV.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imgV.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imgV.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imgV.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return imgV
    }()
    
    lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 2
        lbl.sizeToFit()
        lbl.textAlignment = .center
        addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        lbl.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4).isActive = true
        return lbl
    }()
    
    var text: String = "" {
        didSet {
            label.text = text
            label.sizeToFit()
        }
    }
    
    override func layoutSubviews() {
        backgroundColor = .black
        label.text = text
    }
}

class NoDataGraphView: NoDataView {
    override func layoutSubviews() {
        text =  "No data.\nYou need to workout..."
        super.layoutSubviews()
        backgroundColor = .clear
    }
}
