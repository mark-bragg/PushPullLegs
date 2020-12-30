//
//  BannerAdController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/30/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol BannerAdController {
    func addBannerView()
    func bannerHeight() -> CGFloat
}

extension UIViewController: BannerAdController, GADBannerViewDelegate {
    func addBannerView() {
        guard AppState.shared.isAdEnabled else { return }
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        let container = containerView(bannerHeight())
        if let v =  container.subviews.first(where: { $0.isKind(of: GADBannerView.self) }) {
            v.removeFromSuperview()
        }
        let bannerView = GADBannerView(adSize: adSize)
        add(bannerView, toContainer: container)
        bannerView.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    fileprivate func add(_ bannerView: GADBannerView , toContainer container: UIView) {
        container.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.topAnchor.constraint(equalTo: container.topAnchor, constant: heightBuffer()).isActive = true
        bannerView.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
    }
    
    fileprivate func containerView(_ height: CGFloat) -> UIView {
        if let container = view.viewWithTag(bannerViewContainerTag()) {
            return container
        }
        let container = UIView()
        container.tag = bannerViewContainerTag()
        view.addSubview(container)
        container.backgroundColor = .darkGray
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return container
    }
    
    func bannerHeight() -> CGFloat {
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        let containerHeight = adSize.size.height + (heightBuffer() * 2)
        return containerHeight
    }
    
    fileprivate func heightBuffer() -> CGFloat { 10.0 }
    
    fileprivate func bannerViewContainerTag() -> Int { 98765 }
}
