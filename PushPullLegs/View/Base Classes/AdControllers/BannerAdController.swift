//
//  BannerAdController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/30/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit
import GoogleMobileAds

let spinnerTag = 7469

@objc protocol BannerAdController {
    @objc func addBannerView(_ adUnitID: String)
    @objc func bannerHeight() -> CGFloat
    @objc func refreshBanner()
    @objc func bannerAdUnitID() -> String
}

extension UIViewController: BannerAdController, GADBannerViewDelegate {
    @objc func addBannerView(_ adUnitID: String) {
        guard AppState.shared.isAdEnabled else { return }
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        let container = bannerContainerView(bannerHeight())
        if let v =  container.subviews.first(where: { $0.isKind(of: GADBannerView.self) }) {
            v.removeFromSuperview()
        }
        let bannerView = GADBannerView(adSize: adSize)
        add(bannerView, toContainer: container)
        bannerView.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
        bannerView.adUnitID = adUnitID
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
    
    func bannerContainerView(_ height: CGFloat) -> UIView {
        if let container = view.viewWithTag(bannerViewContainerTag()) {
            return container
        }
        let container = UIView()
        container.tag = bannerViewContainerTag()
        view.addSubview(container)
        container.backgroundColor = .black
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        return container
    }
    
    @objc func bannerHeight() -> CGFloat {
        guard AppState.shared.isAdEnabled else { return 0 }
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(view.frame.width)
        return adSize.size.height + (heightBuffer() * 2)
    }
    
    fileprivate func heightBuffer() -> CGFloat { 10.0 }
    
    fileprivate func bannerViewContainerTag() -> Int { 98765 }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        perform(#selector(refreshBanner), with: self, afterDelay: 2)
    }
    
    @objc func refreshBanner() {
        addBannerView(bannerAdUnitID())
    }
    
    func bannerAdUnitID() -> String {
        AdUnitID.exampleBannerAdUnitID
    }
}
