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
import GoogleMobileAds

var gameOvered:Bool = false
extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    var didLoad:Bool = false
    var skView:SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameCenterHandler.delegate = self
        gameCenterHandler.authenticatePlayer()
    }
    override func viewWillLayoutSubviews() {
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            if !didLoad {
            skView = self.view as! SKView
            skView.ignoresSiblingOrder = true
            scene.size = skView.bounds.size
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
                didLoad = true
            }
            
        }
    }

 /*   override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        gameOvered = true
        let gameOverVC = segue.destinationViewController as! GameOverViewController
        bannerView?.releaseAd()
     //   gameOverVC.transformView()
 //       bannerView?.removeFromSuperview()
    }
    override func viewDidAppear(animated: Bool) {
        gameCenterHandler.delegate = self
        bannerView?.presentInView(self)
        bannerView?.requestAd()
    }
}
