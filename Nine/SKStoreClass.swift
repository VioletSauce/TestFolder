//
//  SKStoreClass.swift
//  Nine
//
//  Created by Alexander Podkopaev on 22.12.14.
//  Copyright (c) 2014 Alexander Podkopaev. All rights reserved.
//

import Foundation
import StoreKit
import UIKit

class SKStoreClass: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
 //   var productsIdentifiers:[String]!
    var observer:SKPaymentTransactionObserver!
    var productsArray:[SKProduct]!
    var delegate:UIViewController!
    var haveObserver:Bool = false
    
    init(identifiers:[String]){
        super.init()
        var request:SKProductsRequest = SKProductsRequest(productIdentifiers: NSSet(array: identifiers))
        request.delegate = self
        request.start()
/*        if !haveObserver {
            SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
*/
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
     //       haveObserver = true
      //  }
    }
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        productsArray = response.products as [SKProduct]
    }
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        let selfDelegate = delegate as UIViewController
        for transaction in transactions {
            if checkReachability() {
                switch transaction.transactionState! {

                case .Purchased:
                    println("Purchased")
                    NSUserDefaults.standardUserDefaults().setValue(IAPEncryptionKey, forKey: "Bundle ID mod")
                case .Failed:
                    if transaction.error != nil {
                        let alert = UIAlertController(title: "An error has occured ", message: "Could not complete transaction (\(transaction.error!!.localizedDescription))", preferredStyle: UIAlertControllerStyle.Alert)
                        let alertAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction!) -> Void in
                        alert.removeFromParentViewController()
                        })
                        alert.addAction(alertAction)
                        delegate.presentViewController(alert, animated: false, completion: nil)
                    }
                case .Purchasing:
                    println("purchasing")
                case .Restored:
                    NSUserDefaults.standardUserDefaults().setValue(IAPEncryptionKey, forKey: "Bundle ID mod")
                    println("restored")
                case .Deferred:
                    println("deferred")

                default:
                    println("Something wrong")
                }
            }
            if transaction.transactionState! == .Purchased || transaction.transactionState! == .Failed || transaction.transactionState! == .Restored{
                queue.finishTransaction(transaction as SKPaymentTransaction)
                let selfGODelegate = selfDelegate as GameOverViewController
                selfGODelegate.hideLoading()
            }
            if transaction.transactionState! == .Purchased || transaction.transactionState! == .Restored {
                isAdsRemoved = true
                adsActive = false
            }
        }
        let timerView = selfDelegate as? GameOverViewController
        timerView?.timer.invalidate()
    }
    
    func buyProduct(atPosition:Int) {
        if productsArray != nil {
            if SKPaymentQueue.canMakePayments() {
                SKPaymentQueue.defaultQueue().addTransactionObserver(self)
                var selfDelegate = delegate as GameOverViewController
                selfDelegate.showLoading()
                SKPaymentQueue.defaultQueue().addPayment(SKMutablePayment(product: productsArray[atPosition]))
            }
        }
    }

    func loadProducts(productIdentifiers:[String]) {
        let request = SKProductsRequest(productIdentifiers: NSSet(array: productIdentifiers))
        request.delegate = self
        request.start()
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
                println("notReachable")
                return false
            }
        }
    }

}