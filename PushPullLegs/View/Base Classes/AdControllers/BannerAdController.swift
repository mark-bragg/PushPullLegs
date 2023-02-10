//
//  BannerAdController.swift
//  PushPullLegs
//
//  Created by Mark Bragg on 12/30/20.
//  Copyright © 2020 Mark Bragg. All rights reserved.
//

import UIKit

let spinnerTag = 7469
let bannerContainerTag = 98765
fileprivate let bannerHolderTag = 6583
//NSUserTrackingUsageDescription
@objc protocol BannerAdController {
    @objc func addBannerView(size: STABannerSize)
    @objc func bannerContainerHeight(size: STABannerSize) -> CGFloat
    @objc func refreshBanner()
    @objc func removeBanner()
}

extension UIViewController: BannerAdController, STABannerDelegateProtocol {
    @objc func addBannerView(size: STABannerSize = STA_PortraitAdSize_320x50) {
        guard AppState.shared.isAdEnabled else { return }
        let container = bannerContainerView(bannerContainerHeight(size: size))
        if let v =  container.viewWithTag(bannerHolderTag) {
            v.removeFromSuperview()
        }
        guard let bannerView = STABannerView(size: size, origin: .zero, withDelegate: self) else { return }
        add(bannerView, toContainer: container)
        bannerView.center = CGPoint(x: container.frame.width / 2, y: container.frame.height / 2)
        bannerView.loadAd()
    }
    
    fileprivate func add(_ banner: STABannerView , toContainer container: UIView) {
        let bannerHolder = UIView()
        container.addSubview(bannerHolder)
        bannerHolder.addSubview(banner)
        bannerHolder.tag = bannerHolderTag
        bannerHolder.translatesAutoresizingMaskIntoConstraints = false
        bannerHolder.heightAnchor.constraint(equalToConstant: banner.frame.height).isActive = true
        bannerHolder.widthAnchor.constraint(equalToConstant: banner.frame.width).isActive = true
        bannerHolder.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        bannerHolder.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
    }
    
    @objc func bannerContainerView(_ height: CGFloat) -> UIView {
        if let container = view.viewWithTag(bannerContainerTag) {
            return container
        }
        let container = UIView()
        container.tag = bannerContainerTag
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
    
    @objc func bannerContainerHeight(size: STABannerSize = STA_PortraitAdSize_320x50) -> CGFloat {
        guard AppState.shared.isAdEnabled else { return 0 }
        let adSize = size.size
        return adSize.height + (heightBuffer() * 2)
    }
    
    @objc func bannerWidth() -> CGFloat {
        view.frame.width
    }
    
    fileprivate func heightBuffer() -> CGFloat { 8.0 }
    
    public func failedLoadBannerAd(_ banner: STABannerView!, withError error: Error!) {
        perform(#selector(refreshBanner), with: self, afterDelay: 5)
    }
    
    public func didSendImpression(forBannerAd banner: STABannerView!) {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(7))) {
            self.refreshBanner()
        }
    }
    
    @objc func refreshBanner() {
        addBannerView()
    }
    
    @objc func removeBanner() {
        guard let container = view.viewWithTag(bannerContainerTag) else { return }
        container.removeFromSuperview()
    }
}
