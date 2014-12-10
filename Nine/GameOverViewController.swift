//
//  GameOverViewController.swift
//  Nine
//
//  Created by Alexander Podkopaev on 05.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import UIKit
import iAd

class GameOverViewController: UIViewController, ADInterstitialAdDelegate {

    var adDidLoad = true
    var loadingAD:Bool = true
    var adView:UIView!
    var loosingStreak:Int = 0
    var failLoad:Int = 0
    
    @IBOutlet weak var scoreNowLabel: UILabel!
    @IBOutlet weak var scoreBestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
  //      loosingStreak++
        requestInterstitialAdPresentation()
        scoreNowLabel.text = "\(score)"
   //     scoreNowLabel.font
        //    if loosingStreak == 5 {
 //       cicleAD()
        //        loosingStreak = 0
        //    }
    }
  //  func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
  //      adView = UIView(frame: self.view.bounds)
  //      closeButton = UIButton(frame: CGRectMake(20, 20, 20, 20))
  //      closeButton.setTitle("X", forState: UIControlState.Normal)
  //      closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
  //      closeButton.addTarget(self, action: Selector("close"), forControlEvents: UIControlEvents.TouchDown)
  //      self.view.addSubview(adView)
  //      self.view.addSubview(closeButton)
  //      fullScreenAd.presentInView(adView)
  //  }
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        loadingAD = true
    }
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
     //   loadingAD = true
     //   if failLoad <= 20 {
      //      cicleAD()
      //      failLoad++
      //      println("RETRYED")
      //  } else {
      //      failLoad = 0
      //      println("Gived up")
      //  }
        
    }

    
    func cicleAD() {
//        if loadingAD {
//            fullScreenAd = ADInterstitialAd()
//            fullScreenAd.delegate = self
//            loadingAD = false
//            requestInterstitialAdPresentation()
//        }
    }
    func close() {
//        self.adView.removeFromSuperview()
//        self.closeButton.removeFromSuperview()
    }
    @IBAction func restartGame(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
        UIViewController.prepareInterstitialAds()
        restarted = true
        notFinishRestarted = true
 //       performSegueWithIdentifier("restartGameSegue", sender: nil)
 //         }
 //   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 //       let gameVC = segue.destinationViewController as GameViewController
 //       didLoad = false
 //       notInited = true

    }
    @IBAction func shareButtonPressed(sender: UIButton) {
        println("pressed!")
    }
}
