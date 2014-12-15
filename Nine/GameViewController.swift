//
//  GameViewController.swift
//  Nine
//
//  Created by Alexander Podkopaev on 28.11.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import UIKit
import SpriteKit
import iAd


var gameOvered:Bool = false
extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}
    var didLoad:Bool = false
class GameViewController: UIViewController, ADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: ADBannerView!
    var skView:SKView!
    

    
    override func viewDidLoad() {
 //       if !didLoad {
        super.viewDidLoad()
 //       self.canDisplayBannerAds = true
        self.bannerView.delegate = self
//        }
    }
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        bannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        bannerView.hidden = true
    }

    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
 //       if currentGameState != gameStages.MainMenu {
       
  //      if currentGameState != gameStages.GamePaused {
  //          gameStateBeforePause = currentGameState
  //      }
  //          currentGameState = gameStages.GamePaused
  //      }
        NSNotificationCenter.defaultCenter().postNotificationName("pauseGamePlease", object: nil)
 //       wasBanner = false
        if touchess == 1 {
            didSucceded = true
            numOfTouches.text = "0"
        }
        return true
    }
    func bannerViewActionDidFinish(banner: ADBannerView!) {
 //       currentGameState = gameStateBeforePause
    }
    
    override func viewWillLayoutSubviews() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            if !didLoad {
            skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
                didLoad = true
            }
            
        }
    }

 /*   override func shouldAutorotate() -> Bool {
        return true
    } */

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        gameOvered = true
        let gameOverVC = segue.destinationViewController as GameOverViewController
//        dismissViewControllerAnimated(false, completion: nil)
        gameOverVC.interstitialPresentationPolicy = ADInterstitialPresentationPolicy.Manual
    }
}
