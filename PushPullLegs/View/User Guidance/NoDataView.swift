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

class NoDataView: UIView {
    var image: UIImage? { UIImage(named: "dumbbells") }
    var imageSideLength: CGFloat { min(frame.height, frame.width) / 2.125 }
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        addSubview(imgV)
        constrainImageView(imgV)
        imgV.rotate(.pi * 1/8)
        return imgV
    }()
    private lazy var backgroundImage: UIImageView = {
        let imgV = UIImageView(image: image)
        addSubview(imgV)
        constrainImageView(imgV)
        imgV.rotate(-.pi * 1/8)
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
        return lbl
    }()
    
    var text: String = "" {
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
        
//        if !spinning {
//            spinner = Timer.publish(every: 0.1, on: .main, in: .default)
//                .autoconnect()
//                .sink(receiveValue: { _ in
//                    self.imageView.rotate(M_2_PI * 0.25)
//                })
//        }
//        if imageView2 == nil {
//            let imageView2 = SpinningFadingImageView()
//            addSubview(imageView2)
//            imageView2.translatesAutoresizingMaskIntoConstraints = false
//            imageView2.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//            imageView2.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//            imageView2.widthAnchor.constraint(equalToConstant: imageSideLength).isActive = true
//            imageView2.heightAnchor.constraint(equalToConstant: imageSideLength).isActive = true
//            imageView2.image = image
//            self.imageView2 = imageView2
//        }
        backgroundImage.image = image
    }
}

class AnimatingImageView: UIImageView {
    var timeLimit: CGFloat? { didSet { handleTimeLimit() } }
    var pauseLimit: CGFloat = 0.1
    var repeater: AnyCancellable?
    override var image: UIImage? {
        didSet {
            guard repeater == nil
            else { return }
            repeater = Timer.publish(every: pauseLimit, on: .main, in: .default)
                .autoconnect()
                .sink(receiveValue: { _ in
                    self.prepareToAnimate()
                })
        }
    }
    
    private func handleTimeLimit() {
        guard let timeLimit, timeLimit <= 0
        else { return }
        
        repeater?.cancel()
    }
    
    private func prepareToAnimate() {
        if let timeLimit {
            self.timeLimit = timeLimit - pauseLimit
        }
        animate()
    }
    
    func animate() {
        // no op
    }
}



class SpinningFadingImageView: AnimatingImageView {
    private var goingUp = false
    private var alphaDelta: CGFloat = 0.1
    var radialDelta: CGFloat = .pi * 2.025
    
    override func animate() {
        rotate(radialDelta)
        
        if goingUp {
            alpha += alphaDelta
            goingUp = alpha < 1
        } else {
            alpha -= alphaDelta
            goingUp = alpha <= 0.1
        }
    }
}

class FadeInAndOutImageView: AnimatingImageView {
    override func animate() {
        
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
