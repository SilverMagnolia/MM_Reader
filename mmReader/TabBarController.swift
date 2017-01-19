//
//  TabBarController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 13..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    
    @IBOutlet weak var tabbar: TabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
}


class TabBar: UITabBar {
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        var sizeThatFits = super.sizeThatFits(size)
        
        sizeThatFits.height = 70
        
        return sizeThatFits
        
    }
}
