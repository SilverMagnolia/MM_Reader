//
//  CustomTabBarController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 22..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class CustomTabBarController: UIViewController {
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var tabButtons: [UIButton]!
    
    private var subViewControllers: [UIViewController]! = [UIViewController]()
    private var selectedIdx: Int!
    private var defaultTabBarAffineTransform: CGAffineTransform!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.selectedIdx = 0
        
        let storyboard = UIStoryboard(name: "mmMain", bundle: nil)
        
        // instantiate tab bar's subviews
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "MyLibraryNavigationController"))
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "FullListNavigationController"))
        self.subViewControllers.append(storyboard.instantiateViewController(withIdentifier: "InformationNavigationController"))
        
        // set default subview
        self.tabButtons[self.selectedIdx].isSelected = true
        didPressTab(self.tabButtons[self.selectedIdx])
        
        // notification
        NotificationCenter.default.addObserver(self, selector: #selector(CustomTabBarController.hideTabBar(_:)), name: Notification.Name(rawValue: "hideTabBar"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CustomTabBarController.showTabBar(_:)), name: Notification.Name(rawValue: "showTabBar"), object: nil)
        
        self.defaultTabBarAffineTransform = self.tabBarView.transform
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
    
    internal func hideTabBar(_ notification: Notification) {
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in

            self.contentViewBottomConstraint.constant = self.tabBarView.bounds.height
            self.view.layoutIfNeeded()
            
        })
    }
    
    internal func showTabBar(_ notification: Notification) {
        UIView.animate(withDuration: 0.15, animations: {
            () -> Void in
            
            self.contentViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
            
        })
        
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


