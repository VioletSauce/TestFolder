//
//  GameOverViewController.swift
//  Nine
//
//  Created by Alexander Podkopaev on 05.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import UIKit
import iAd
import CoreData
import StoreKit

class GameOverViewController: UIViewController, ADBannerViewDelegate, ADInterstitialAdDelegate, SKPaymentTransactionObserver {

    var adDidLoad = true
    var loadingAD:Bool = true
    var adView:UIView!
    var loosingStreak:Int = 0
    var failLoad:Int = 0
    
    var SavedScoress:NSManagedObject!
    var managedContext:NSManagedObjectContext!
    
    @IBOutlet weak var scoreNowLabel: UILabel!
    @IBOutlet weak var scoreBestLabel: UILabel!
    @IBOutlet weak var adBannerView: ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        managedContext = appDel.managedObjectContext

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
  //      loosingStreak++
        adBannerView.delegate = self
        let request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("SavedScores", inManagedObjectContext: managedContext)
        request.entity = entity
        var scores:NSArray = managedContext.executeFetchRequest(request, error: nil)!
        var highScores:Int = 0
        if scores.count == 0 {
            var newScores = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            managedContext.save(nil)
            scores = managedContext.executeFetchRequest(request, error: nil)!

        }
        println(scores.count)
            highScores = scores[0].valueForKey("highScore") as Int
        println(highScores)
        if highScores < score {
            scores[0].setValue(score, forKey: "highScore")
            managedContext.save(nil)
            scoreBestLabel.text = "\(score)"

        } else {
            scoreBestLabel.text = "\(highScores)"
        }
        scoreBestLabel.font = UIFont(name: "\(scoreBestLabel.font.fontName)", size: scoreBestLabel.frame.size.height)
        scoreNowLabel.text = "\(score)"
        scoreNowLabel.font = UIFont(name: "\(scoreNowLabel.font.fontName)", size: scoreNowLabel.frame.size.height)
        requestInterstitialAdPresentation()

    }
        
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        loadingAD = true
    }
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
  //      var userData:NURL
        for transaction in transactions {
            switch(transaction.transactionState!) {
            case .Purchased:
//NSUserDefaults.standardUserDefaults().
                println("perc")
            case .Restored:
                println("rest")
            case .Failed:
                if transaction.errorStatusCode != SKErrorPaymentCancelled {
                }
                println("fail")
            default:
                println("other")
            }
            SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue!, removedTransactions transactions: [AnyObject]!) {
    }
    
    
    @IBAction func restartGame(sender: UIButton) {
        Flurry.logEvent("GameRestartedAfterGameOver")
        dismissViewControllerAnimated(false, completion: nil)
        UIViewController.prepareInterstitialAds()
        restarted = true
        notFinishRestarted = true

    }
    @IBAction func shareButtonPressed(sender: UIButton) {
        let shareActivity = "I score a \(score) in 9! Can you beat me?"
        let activityVC:UIActivityViewController = UIActivityViewController(activityItems: [shareActivity], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
        Flurry.logEvent("ShareButtonPressed", withParameters: NSDictionary(object: score, forKey: "ScoreWhenShared"))
    }
 /*   @IBAction func removeAdsButtonPressed(sender: UIButton) {
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        if SKPaymentQueue.canMakePayments() {
            var removeAdsPayment:SKMutablePayment = SKMutablePayment(product: products[0] as SKProduct)
            removeAdsPayment.quantity = 1
            SKPaymentQueue.defaultQueue().addPayment(removeAdsPayment)
        }
    } */
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerView.hidden = false
 //       println("succeded")
    }
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView.hidden = true
 //       println("failed")
    } 
    
}
