//
//  AppDelegate.swift
//  pokemongo
//
//  Created by Angel Lim on 7/11/16.
//  Copyright © 2016 Angel Lim. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyDLuWfNN2HM2EEWqV6MZPBACJ-1Ka5loAE")
        
        FIRApp.configure()
        
        FIRDatabase.database().persistenceEnabled = true
        


        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if (!isAppAlreadyLaunchedOnce()) {
            let rootController = storyboard.instantiateViewControllerWithIdentifier("pageTeam") as UIViewController!
            //            print("first time launch! play tutorial")
            if let window = self.window {
                window.rootViewController = rootController
            }
        } else {
            let rootController = storyboard.instantiateViewControllerWithIdentifier("pageTeam") as UIViewController!
            if let window = self.window {
                window.rootViewController = rootController
            }
        }
        if(isAppAlreadyLaunchedOnce()) {
            //            print("ayo this guy launched before")
        }
        
        


        return true
    }
    
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let isAppAlreadyLaunchedOnce = defaults.stringForKey("isAppAlreadyLaunchedOnce"){
            return true
        }else{
            defaults.setBool(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }


    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

