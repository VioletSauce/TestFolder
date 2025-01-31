//
//  AppDelegate.swift
//  Nine
//
//  Created by Alexander Podkopaev on 28.11.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import UIKit
import CoreData
import GameKit
import SystemConfiguration
import Foundation
import StoreKit

var gameCenterEnabled:Bool = false
var lbID:String = "0"
var GChighScore:Int64 = 0

var SKStoreHandler:SKStoreClass!
var gameCenterHandler:gameCenter!

var isAdsRemoved:Bool = false

var bannerView:BannerViewClass!
var adsActive:Bool = true

var IAPEncryptionKey:Int = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
     //   Flurry.startSession("9XK5T52Y5TKHGFNNR8TN")  
        if NSUserDefaults.standardUserDefaults().valueForKey("Bundle ID mod") == nil {
            NSUserDefaults.standardUserDefaults().setObject(0, forKey: "Bundle ID mod")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        if checkReachability() {
            SKStoreHandler = SKStoreClass(identifiers: ["AdsFreeNine"])
     //       self.authenticatePlayer()
            removedAds()
        } else {
            adsActive = false
        }
        bannerView = BannerViewClass(adID: "ca-app-pub-8371737787665531/5139756806")
        gameCenterHandler = gameCenter()
        return true
    }
    
    func removedAds() {
        if !isAdsRemoved {
            IAPEncryptionKey = createEncryptionKey()
            if IAPEncryptionKey == NSUserDefaults.standardUserDefaults().valueForKey("Bundle ID mod")! as! Int {
                isAdsRemoved = true
            } else {
                adsActive = true
            }
        }
    }
    
    func createEncryption() -> Int {
        var encryptionKeyStringArray:[Character] = Array(UIDevice.currentDevice().identifierForVendor.UUIDString)
        encryptionKeyStringArray = encryptionKeyStringArray.filter { (T) -> Bool in
            if T == "0" || T == "1" || T == "2" || T == "3" || T == "4" || T == "5" || T == "6" || T == "7" || T == "8" || T == "9" {
                return true
            } else {
                return false
            }
        }
        var encryptionKeyIntArray:[Int] = encryptionKeyStringArray.map { (T:Character) -> Int in
            let a = String(T)
            return a.toInt()!
        }
        var encryption:Int = 0
        encryptionKeyIntArray.removeLast()
        for newNum in encryptionKeyIntArray {
            encryption += newNum
        }
        return encryption
    }
    
    func createEncryptionKey() -> Int {
        var encryptionKey:Int = createEncryption()
        encryptionKey *= 54
        encryptionKey += 4265
        println(encryptionKey)
        return encryptionKey
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

    func applicationWillResignActive(application: UIApplication) {
        if currentGameState == gameStages.GameGoing && !gamePaused{
            NSNotificationCenter.defaultCenter().postNotificationName("pauseGamePlease", object: nil)
            gamePaused = true
        }
        gameCenterEnabled = false
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {

    }
    
    lazy var applicationDocumetnsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("ScoreFile", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumetnsDirectory.URLByAppendingPathComponent("Nine.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data"
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "APDEL_STORAGE_UNABLE_TO_SAVE", code: 9999, userInfo: dict as NSDictionary as [NSObject : AnyObject])
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext:NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()

    func saveContext() {
        if let moc = self.managedObjectContext {
            var error:NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
  }

