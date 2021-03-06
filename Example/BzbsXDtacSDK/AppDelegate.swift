//
//  AppDelegate.swift
//  BzbsXDtacSDK
//
//  Created by natchaporing@gmail.com on 09/13/2019.
//  Copyright (c) 2019 natchaporing@gmail.com. All rights reserved.
//

import UIKit
import GoogleMaps
import BzbsXDtacSDK
import Firebase
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        iOS Test Key :
//
//        th.co.dtac.beta
//        com.buzzebees.xDtac
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyD16TFAFMmV0bsu8Hi-kkGFS8dYkWPtIM0")
        MSAppCenter.start("909eb374-e9b4-4369-a09a-2f23bbe1cc03", withServices:[
          MSAnalytics.self,
          MSCrashes.self
        ])
        UINavigationBar.appearance().backgroundColor = .blue
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NotificationCenter.default.post(name: NSNotification.Name.BzbsViewDidBecomeActive, object: nil)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        Bzbs.shared.actionDeeplink(url: url)
        return true
    }

}

