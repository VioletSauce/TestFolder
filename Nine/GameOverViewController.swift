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

class GameOverViewController: UIViewController, ADInterstitialAdDelegate {

    var adDidLoad = true
    var loadingAD:Bool = true
    var adView:UIView!
    var loosingStreak:Int = 0
    var failLoad:Int = 0
    
    var SavedScoress:NSManagedObject!
    var managedContext:NSManagedObjectContext!
    
    @IBOutlet weak var scoreNowLabel: UILabel!
    @IBOutlet weak var scoreBestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDel = UIApplication.sharedApplication().delegate as AppDelegate
        managedContext = appDel.managedObjectContext

//        println("aaa)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidAppear(animated: Bool) {
  //      loosingStreak++
        let request = NSFetchRequest()
        var entity = NSEntityDescription.entityForName("SavedScores", inManagedObjectContext: managedContext)
        request.entity = entity
        var scores:NSArray = managedContext.executeFetchRequest(request, error: nil)!
        var highScores:Int = scores[0].valueForKey("highScore") as Int
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
 //           gameOvered = false
//        }

    }
        
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        loadingAD = true
    }
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
    }
    
    func saveContent(scoreGet:Int) {
        
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
}
