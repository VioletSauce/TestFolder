//
//  BannerViewClass.swift
//  Nine
//
//  Created by Alexander Podkopaev on 24.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import Foundation
import iAd
import GoogleMobileAds

class BannerViewClass:NSObject, GADBannerViewDelegate {
 
    var bannerView:GADBannerView!
    var request:GADRequest!
    
   required init(coder aDecoder: NSCoder) {
    //    super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    init(adID:String) {
        super.init()
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait, origin: CGPointMake(0, 0))
        bannerView.adUnitID = adID
        request = GADRequest()
        request.testDevices = NSArray(objects: adID) as! [String]
   //     bannerView.loadRequest(request)
        bannerView.delegate = self
        bannerView.hidden = true
    //    self.view.addSubview(bannerView)
    }
    
    func requestAd() {
        if !isAdsRemoved && adsActive {
            bannerView.loadRequest(request)
        }
    }
    
    func presentInView(viewController:UIViewController) {
        if !isAdsRemoved && adsActive {
            bannerView.removeFromSuperview()
            bannerView.rootViewController = viewController
            viewController.view.addSubview(bannerView)
        }
    }
    
    func releaseAd() {
        if !isAdsRemoved && adsActive {
            bannerView.removeFromSuperview()
        }
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        if !isAdsRemoved && adsActive {
            bannerView.hidden = true
        }
    }
    func adViewDidReceiveAd(view: GADBannerView!) {
        if !isAdsRemoved && adsActive {
            bannerView.hidden = false
        }
    }
    
    func adViewWillPresentScreen(adView: GADBannerView!) {
        if currentGameState != gameStages.GameOver {
            NSNotificationCenter.defaultCenter().postNotificationName("PauseGamePlease", object: nil)
        }
    }
}