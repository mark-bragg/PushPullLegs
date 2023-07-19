//
//  NoDataView.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 8/13/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import Combine
import UIKit

extension UIView {
    func rotate(_ degrees: CGFloat) {
        transform = CGAffineTransformRotate(transform, degrees)
    }
}

class NoDataViewController: UIViewController {
    var text: String?
    private weak var noDataView: NoDataView?
    
    func showNoData(y: CGFloat) {
        var frame = view.bounds
        frame.origin.y = y
        let ndv = NoDataView(frame: frame)
        view.addSubview(ndv)
        self.noDataView = ndv
        ndv.text = text
        view.superview?.bringSubviewToFront(view)
    }
    
    func hideNoData() {
        noDataView?.removeFromSuperview()
        view.superview?.sendSubviewToBack(view)
    }
}

class NoDataView: UIView {
    var image: UIImage? { UIImage(named: "dumbbells") }
    var imageSideLength: CGFloat { min(frame.height, frame.width) / 2.125 }
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        addSubview(imgV)
        constrainImageView(imgV)
        imgV.rotate(.pi * 1/8)
        imgV.alpha = 0.75
        return imgV
    }()
    private lazy var backgroundImage: UIImageView = {
        let imgV = UIImageView(image: image)
        addSubview(imgV)
        constrainImageView(imgV)
        imgV.rotate(-.pi * 1/8)
        imgV.alpha = 0.75
        return imgV
    }()
    var spinning: Bool { spinner != nil }
    var spinner: AnyCancellable?
    
    var labelY: CGFloat { imageSideLength / 2 }
    lazy var label: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 1
        lbl.sizeToFit()
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        addSubview(lbl)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: labelY).isActive = true
        lbl.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        lbl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8.0).isActive = true
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.2
        return lbl
    }()
    
    var text: String? = "" {
        didSet {
            label.text = text
            label.sizeToFit()
            label.heightAnchor.constraint(equalToConstant: label.frame.height).isActive = true
        }
    }
    
    private func constrainImageView(_ imgV: UIImageView) {
        imgV.translatesAutoresizingMaskIntoConstraints = false
        imgV.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        imgV.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imgV.widthAnchor.constraint(equalToConstant: imageSideLength).isActive = true
        imgV.heightAnchor.constraint(equalToConstant: imageSideLength).isActive = true
    }
    
    override func layoutSubviews() {
        backgroundColor = .black
        label.text = text
        imageView.image = image?.withTintColor(.blue, renderingMode: .alwaysTemplate)
        backgroundImage.image = image
    }
}

class NoDataGraphView: NoDataView {
    override var labelY: CGFloat { 4 }
    
    override func layoutSubviews() {
        if text == "" {
            label.font = UIFont.systemFont(ofSize: 14, weight: .light)
            text =  "No data. You need to workout..."
        }
        super.layoutSubviews()
        backgroundColor = .clear
    }
}
