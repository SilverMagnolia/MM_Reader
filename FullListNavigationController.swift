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
        
        
        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    
    func navigationController(_ navigationController: UINavigationController,  willShow viewController: UIViewController, animated: Bool) {
        
        if viewController is BookInfoDetailViewController {
            
            // hide tab bar
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideTabBar"), object: nil)
            
        }
        
        if viewController is FullListController {
            
            // show tab bar
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showTabBar"), object: nil)
            
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
