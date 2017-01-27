//
//  CustomTabBarController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 22..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class CustomTabBarController: UIViewController {

    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabButtons: [UIButton]!
    
    private var subViewControllers: [UIViewController]! = [UIViewController]()
    private var selectedIdx: Int!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedIdx = 0
        
        let storyboard = UIStoryboard(name: "mmMain", bundle: nil)
        
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "MyLibraryNavigationController"))
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "FullListNavigationController"))
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "InformationNavigationController"))
        
        self.tabButtons[self.selectedIdx].isSelected = true
        didPressTab(self.tabButtons[self.selectedIdx])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        
        let previousButtonIdx = self.selectedIdx
        self.selectedIdx = sender.tag
        
        self.tabButtons[previousButtonIdx!].isSelected = false
        
        let previousVC = self.subViewControllers[previousButtonIdx!]
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
        
        sender.isSelected = true
        
        let selectedVC = self.subViewControllers[self.selectedIdx]
        
        self.addChildViewController(selectedVC)
        selectedVC.view.frame = self.contentView.bounds
        self.contentView.addSubview(selectedVC.view)
        
        selectedVC.didMove(toParentViewController: self)
        
    }
}

extension UINavigationBar {
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width/6)
    }
 
    func setCustomBackground() {
        self.setBackgroundImage(UIImage(named: "Navigation_background"), for: .default)
    }
}


