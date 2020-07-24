//
//  AppDelegate.swift
//  ConfigKit
//
//  Created by Will Powell on 01/26/2017.
//  Copyright (c) 2017 Will Powell. All rights reserved.
//

import UIKit
import ConfigKit
import Reachability
import DictionaryUtils

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let reachability = try! Reachability()
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        if ConfigKit.startFromPlist() == false {
            ConfigKit.start(branch: "demo", account: "b")
        }
        ConfigKit.getConfig(str: "compile") { (err, data, source) in
            print("Loaded")
        }
        
        
        let data = ["TEST":["hello":"WELCOME"]]
        do{
            if let output = try data.read("TEST.hello") {
                print(String(describing:output))
            }
        }catch{
            print("error Parsing")
        }
        
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
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

