//
//  FullListNavigationController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 27..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class FullListNavigationController: UINavigationController, UINavigationControllerDelegate {

    private var unableToNetworkView: UnableToNetworkView?
    private var bookDetailsVCInDownloadProgress = [BookDetailsController]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(FullListNavigationController.deleteBookDetailsInstanceCompletedToDownload(_: )), name: Notification.Name(rawValue: "deleteBookDetails"), object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        /*
         if the VC pushed into the navigation stack was downloading epub
         when it was popped out of stack previously, 
         and the downloading task is still in progress 
         when it is selected again, the instance stored in array is used, 
         not the instance newly created.
        */
        
        if viewController is BookDetailsController,
            let title = (viewController as! BookDetailsController).titleStr {
            
            if let VCDownloadingEpub = checkIfCurrentVCSeguedIsInDownload(with: title) {
                
                // push the BookDetailsVC instance stored in array.
                super.pushViewController(VCDownloadingEpub, animated: true)
                return
            }
        }
        
        // push the BookDetailsVC instance newly created.
        super.pushViewController(viewController, animated: true)
    }
    
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        /*
         if the VC popped out of navigation stack is downloading epub,
         it has to be stored in array for reuse in certain condition.
         it will be removed from array when the download task is completed.
        */
        
        let VC = super.popViewController(animated: true)
        
        if VC is BookDetailsController {
            
            if (VC as! BookDetailsController).isDownloadInProgress,
                checkIfCurrentVCSeguedIsInDownload(with: (VC as! BookDetailsController).titleStr!) == nil
            {
                self.bookDetailsVCInDownloadProgress.append(VC as! BookDetailsController)
            }
        }
        
        return VC
    }
    
    
    func deleteBookDetailsInstanceCompletedToDownload(_ notification: Notification) {
        /*
         an element of [bookDetailsVCInDownloadProgress] will be removed
         when its downloading task is completed.
         the post for this notification is sent from BookDetailsController.
        */
        for i in 0...(self.bookDetailsVCInDownloadProgress.count - 1) {
            
            if bookDetailsVCInDownloadProgress[i].titleStr == (notification.object as! String) {
                bookDetailsVCInDownloadProgress.remove(at: i)
                
                return
            }
        }
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

    
    internal func showUnableToNetworkView() {
        
        if self.unableToNetworkView == nil {
            
            self.unableToNetworkView = UnableToNetworkView()
            self.unableToNetworkView?.center = self.view.center
            self.view.addSubview((unableToNetworkView)!)
            addConstraintsToUnableToNetworkView()
            
        }
    }
    
    internal func hideUnableToNetworkView() {
        
        if self.unableToNetworkView != nil {
            
            self.unableToNetworkView!.removeFromSuperview()
            self.unableToNetworkView = nil
            
        }
    }
    
    private func addConstraintsToUnableToNetworkView() {
        
        /*
         this method sets auto-layout to unableToNetworkView.
        */
        
        self.unableToNetworkView?.translatesAutoresizingMaskIntoConstraints = false
        
        var constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: .top, relatedBy: .equal, toItem: self.navigationBar, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
    }
    
    private func checkIfCurrentVCSeguedIsInDownload(with title: String) -> BookDetailsController? {
        
        for bookDetailsVC in self.bookDetailsVCInDownloadProgress {
            
            if bookDetailsVC.titleStr == title {
                return bookDetailsVC
            }
        }
        
        return nil
    }
    
}
