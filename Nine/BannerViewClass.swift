//
//  BannerViewClass.swift
//  Nine
//
//  Created by Alexander Podkopaev on 24.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import Foundation
import iAd

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
        request.testDevices = [GAD_SIMULATOR_ID]
   //     bannerView.loadRequest(request)
        bannerView.delegate = self
        bannerView.hidden = true
    //    self.view.addSubview(bannerView)
    }
    
    func requestAd() {
        bannerView.loadRequest(request)
    }
    
    func presentInView(viewController:UIViewController) {
        println("1")
        bannerView.removeFromSuperview()
                println("2")
        bannerView.rootViewController = viewController
                println("3")
        viewController.view.addSubview(bannerView)
                println("4")
    }
    
    func releaseAd() {
        bannerView.removeFromSuperview()
    }
    
    func adView(view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        bannerView.hidden = true
    }
    func adViewDidReceiveAd(view: GADBannerView!) {
        bannerView.hidden = false
    }
    
    func adViewWillPresentScreen(adView: GADBannerView!) {
        if currentGameState != gameStages.GameOver {
            NSNotificationCenter.defaultCenter().postNotificationName("PauseGamePlease", object: nil)
        }
    }
}