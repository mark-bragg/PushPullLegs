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
let bannerTag = 98765

@objc protocol BannerAdController {
    @objc func addBannerView()
    @objc func bannerContainerHeight() -> CGFloat
    @objc func refreshBanner()
    @objc func bannerAdUnitID() -> String
    @objc func removeBanner()
}

extension UIViewController: BannerAdController, GADBannerViewDelegate {
    @objc func addBannerView() {
        guard AppState.shared.isAdEnabled else { return }
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth())
        let container = bannerContainerView(bannerContainerHeight())
        if let v =  container.subviews.first(where: { $0.isKind(of: GADBannerView.self) }) {
            v.removeFromSuperview()
        }
        let bannerView = GADBannerView(adSize: adSize)
        add(bannerView, toContainer: container)
        bannerView.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
        bannerView.adUnitID = bannerAdUnitID()
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
    
    @objc func bannerContainerView(_ height: CGFloat) -> UIView {
        if let container = view.viewWithTag(bannerViewContainerTag()) {
            return container
        }
        let container = UIView()
        container.tag = bannerViewContainerTag()
        view.addSubview(container)
        container.backgroundColor = .black
        constrainContainerView(container, height)
        return container
    }
    
    fileprivate func constrainContainerView(_ container: UIView, _ height: CGFloat) {
        container.translatesAutoresizingMaskIntoConstraints = false
        container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        container.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        container.heightAnchor.constraint(equalToConstant: height).isActive = true
        container.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func bannerContainerHeight() -> CGFloat {
        guard AppState.shared.isAdEnabled else { return 0 }
        let adSize = GADPortraitAnchoredAdaptiveBannerAdSizeWithWidth(bannerWidth())
        return adSize.size.height + (heightBuffer() * 2)
    }
    
    @objc func bannerWidth() -> CGFloat {
        view.frame.width
    }
    
    fileprivate func heightBuffer() -> CGFloat { 10.0 }
    
    fileprivate func bannerViewContainerTag() -> Int { bannerTag }
    
    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        perform(#selector(refreshBanner), with: self, afterDelay: 2)
    }
    
    @objc func refreshBanner() {
        addBannerView()
    }
    
    func bannerAdUnitID() -> String {
        ""
    }
    
    @objc func removeBanner() {
        guard let container = view.viewWithTag(bannerViewContainerTag()) else { return }
        container.removeFromSuperview()
    }
}
