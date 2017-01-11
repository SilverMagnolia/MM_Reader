//
//  AppDelegate.swift
//  mmReader
//
//  Created by 박종호 on 2016. 10. 17..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    var backgroundSessionCompletionHandler: (() -> Void)?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        print("\n\napplicationWillResignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\n\naplicationDidEnterBackground")
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("\n\napplicationWillEnterForeground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("\n\napplicationDidBecomeActive")
        /*
        let root = self.window!.rootViewController
        
        if root is UITabBarController,
            (root as! UITabBarController).selectedIndex == 1{
            
            // if current visible view is BookInfoDetailViewController.
            if let secondNavigationController = (root as! UITabBarController).selectedViewController,
                (secondNavigationController as! UINavigationController).visibleViewController is BookInfoDetailViewController
                
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didBecomeActiveOnDetailView"), object: nil)
                
            }
            
            // if currne visible view is FullListController.
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didBecomeActiveOnFullList"), object: nil)
        }*/
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(handleEventsForBackgroundURLSession
        identifier: String, completionHandler: @escaping () -> Void) {
        print("\nhandleEventsForBackgroundURLSession\n")
        backgroundSessionCompletionHandler = completionHandler
    
    }


}

