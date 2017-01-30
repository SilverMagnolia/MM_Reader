//
//  FullListNavigationController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 27..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class FullListNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func navigationController(_ navigationController: UINavigationController,  willShow viewController: UIViewController, animated: Bool) {
        
        /**
         when user select a table view's cell,
         NotificationCenter notifies to "CustomTabBarController"
         so that the lower custom tab bar will be hided.
         It also works in the contrast condition.
        */
        
        if viewController is BookDetailsController {
            
            // hide tab bar
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideTabBar"), object: nil)
            
        }
        
        if viewController is FullListController {
            
            // show tab bar
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showTabBar"), object: nil)
            
        }
    }
}
