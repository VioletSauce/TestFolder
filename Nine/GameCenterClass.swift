//
//  GameCenterClass.swift
//  Nine
//
//  Created by Alexander Podkopaev on 19.01.15.
//  Copyright (c) 2015 Alexander Podkopaev. All rights reserved.
//

import Foundation
import GameKit

class gameCenter {

    var localPlayer:GKLocalPlayer!
    var leaderBoard:GKLeaderboard!
    var delegate:UIViewController!
    var wasID:String!
    var noMore:Bool = false
    init() {
        localPlayer = GKLocalPlayer.localPlayer()
        authenticatePlayer()
    }
    func authenticatePlayer() {
        localPlayer.authenticateHandler = {(uiVC:UIViewController!, error:NSError!) -> Void in
            if uiVC != nil && !self.noMore {
                self.delegate.presentViewController(uiVC, animated: true, completion: nil)
            } else if self.localPlayer.authenticated {
                gameCenterEnabled = true
                if self.localPlayer.playerID != self.wasID {
                    self.localPlayer = GKLocalPlayer.localPlayer()
                    self.loadLB()
                }
            } else {
                gameCenterEnabled = false
            }
        }
    }
    func loadLB() {
        self.localPlayer.loadDefaultLeaderboardIdentifierWithCompletionHandler({(identifier:String!, error:NSError!) -> Void in
            if error != nil {
                NSLog("String", error.localizedDescription)
            } else {
                lbID = identifier
                self.leaderBoard = GKLeaderboard()
                self.leaderBoard.identifier = lbID
                self.leaderBoard.loadScoresWithCompletionHandler { (scores:[AnyObject]!, error:NSError!) -> Void in
                    if error != nil {
                        NSLog("String", error.localizedDescription)
                    }
                    if scores != nil {
                        if self.leaderBoard.localPlayerScore != nil {
                            GChighScore = self.leaderBoard.localPlayerScore.value as Int64
                        } else {
                            GChighScore = 0
                        }
                    }
                }
                
            }
        })
    }
}
