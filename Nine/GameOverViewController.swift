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
import GameKit

var loosingStreak:Int = 0
var interstitialAd:GADInterstitial!

class GameOverViewController: UIViewController/* GADBannerViewDelegate*/, GADInterstitialDelegate, SKPaymentTransactionObserver, GKGameCenterControllerDelegate {
    
    var interAdWasUsed:Bool = false
    
    var SavedScoress:NSManagedObject!
    var managedContext:NSManagedObjectContext!
    
    @IBOutlet weak var scoreNowLabel: UILabel!
    @IBOutlet weak var scoreBestLabel: UILabel!
    
    @IBOutlet weak var loadingImageView: UIImageView!
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buyButtonImage: UIImageView!
    @IBOutlet weak var buyButtonOutlet: UIButton!
    @IBOutlet weak var rateButtonForColor: UIButton!
    
    lazy var timer = NSTimer()
    
    var color:UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if adsActive && !isAdsRemoved{
            interstitialAd = cicleInterstitialAd()
        }
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        managedContext = appDel.managedObjectContext
        color = buyButtonOutlet.backgroundColor
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
        bannerView?.presentInView(self)

        transformView()
        calculateScores()
        if !checkReachability() {
            bannerView = nil
        } else {
            if bannerView == nil {
                bannerView = BannerViewClass(adID: "ca-app-pub-8371737787665531/5139756806")
            }
        }
        if !isAdsRemoved {
            if loosingStreak >= 2 {
                if interstitialAd != nil {
                    if interstitialAd.isReady && !interAdWasUsed {
                        interstitialAd.presentFromRootViewController(self)
                        interAdWasUsed = true
                        loosingStreak = 0
                    }
                }
            }
        }
        if loosingStreak >= 1000000 {
            loosingStreak = 0
        }

    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions {
            switch(transaction.transactionState!) {
            case .Purchased:
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
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func interstitialDidDismissScreen(ad: GADInterstitial!) {
        interstitialAd = nil
        interstitialAd = cicleInterstitialAd()
    }
    
    
    func loadScores(){
        var leaderBoard:GKLeaderboard = GKLeaderboard()
        leaderBoard.identifier = lbID
        leaderBoard.loadScoresWithCompletionHandler { (scores:[AnyObject]!, error:NSError!) -> Void in
            if error != nil {
                NSLog("String", error.localizedDescription)
            }
            if scores != nil {
                GChighScore = leaderBoard.localPlayerScore.value as Int64
            }
        }
    }
    
    func calculateScores() {
        if !GKLocalPlayer.localPlayer().authenticated {
            gameCenterEnabled = false
        } else if !gameCenterEnabled{
            gameCenterEnabled = true
        }
        var GCScore:Int64!
        var GKScoreObj:GKScore!
        if gameCenterEnabled {
            GKScoreObj = GKScore(leaderboardIdentifier: lbID)
            GCScore = GChighScore
        }
        let request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("SavedScores", inManagedObjectContext: managedContext)
        request.entity = entity
        var scores:NSArray = managedContext.executeFetchRequest(request, error: nil)!
        var highScores:Int = 0
        if scores.count == 0 {
            var newScores = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            managedContext.save(nil)
            scores = managedContext.executeFetchRequest(request, error: nil)!
            highScores = scores[0].valueForKey("highScore") as Int
        } else {
            highScores = scores[0].valueForKey("highScore") as Int
        }
        if highScores < score {
            scores[0].setValue(score, forKey: "highScore")
        }
        highScores = scores[0].valueForKey("highScore") as Int
        if gameCenterEnabled {
            if highScores > Int(GCScore) {
                GKScoreObj.value = Int64(highScores)
                GKScore.reportScores([GKScoreObj], withCompletionHandler: { (error:NSError!) -> Void in
                    if error != nil {
                        NSLog("String", error.localizedDescription)
                    }
                })
            }
        }
        highScores = scores[0].valueForKey("highScore") as Int
        managedContext.save(nil)
        scoreBestLabel.text = "\(highScores)"
        scoreBestLabel.font = UIFont(name: "\(scoreBestLabel.font.fontName)", size: scoreBestLabel.frame.size.height)
        scoreNowLabel.text = "\(score)"
        scoreNowLabel.font = UIFont(name: "\(scoreNowLabel.font.fontName)", size: scoreNowLabel.frame.size.height)
        if gameCenterEnabled {
            loadScores()
        }
    }
    
    func cicleInterstitialAd() -> GADInterstitial{
        let newInterAd:GADInterstitial = GADInterstitial()
        newInterAd.delegate = self
        newInterAd.adUnitID = "ca-app-pub-8371737787665531/5139756806"
        let request:GADRequest = GADRequest()
        request.testDevices = [GAD_SIMULATOR_ID]
        newInterAd.loadRequest(request)
        return newInterAd
    }
    
    func transformView() {
        if !checkReachability() || isAdsRemoved {
            buyButtonOutlet.backgroundColor = rateButtonForColor.backgroundColor
            buyButtonOutlet.userInteractionEnabled = false
            adsActive = false
            interstitialAd = nil
        } else {
            if SKStoreHandler == nil {
                SKStoreHandler = SKStoreClass(identifiers: ["AdsFreeNine"])
            }
            buyButtonOutlet.backgroundColor = color
            buyButtonOutlet.userInteractionEnabled = true
            if interstitialAd == nil {
                interstitialAd = cicleInterstitialAd()
            }
            adsActive = true
        }
    }
    
    func showLoading() {
        loadingImageView.hidden = false
        loadingActivityIndicator.hidden = false
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("hideLoading"), userInfo: nil, repeats: false)
    }
    
    func hideLoading() {
        loadingImageView.hidden = true
        loadingActivityIndicator.hidden = true
    }
    
    func checkReachability() -> Bool {
        var reachability:Reachability = Reachability.reachabilityForLocalWiFi()
        var networkStatus:NetworkStatus = reachability.currentReachabilityStatus()
        if networkStatus.value != NotReachable.value {
            return true
        } else {
            reachability = Reachability.reachabilityForInternetConnection()
            networkStatus = reachability.currentReachabilityStatus()
            if networkStatus.value != NotReachable.value {
                return true
            } else {
                return false
            }
        }
    }
    
    @IBAction func restartGame(sender: UIButton) {
        loosingStreak++
        Flurry.logEvent("GameRestartedAfterGameOver")
        dismissViewControllerAnimated(false, completion: nil)
        restarted = true
        interAdWasUsed = false
        notFinishRestarted = true

    }
    @IBAction func shareButtonPressed(sender: UIButton) {
        let shareActivity = "I score a \(score) in 9! Can you beat me?"
        let activityVC:UIActivityViewController = UIActivityViewController(activityItems: [shareActivity], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
        Flurry.logEvent("ShareButtonPressed", withParameters: NSDictionary(object: score, forKey: "ScoreWhenShared"))
    }
    @IBAction func removeAdsButtonPressed(sender: UIButton) {
        if checkReachability() {
            showLoading()
            SKStoreHandler?.delegate = self
            SKStoreHandler?.buyProduct(0)
        }

    }
    @IBAction func showLeaderboard(sender: UIButton) {
        var lbViewController:GKGameCenterViewController = GKGameCenterViewController()
        lbViewController.gameCenterDelegate = self
        lbViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        lbViewController.leaderboardIdentifier = lbID
        self.presentViewController(lbViewController, animated: true, completion: nil)
    }
}
