//
//  BookDetailsCustomTabBarViewController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 30..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class BookDetailsCustomTabBarController: UIViewController {
    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var selectedIdx: Int!
    var htmlRequests: [URLRequest]!
    var bookTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.title = self.bookTitle
        self.tabButtons[self.selectedIdx].isSelected = true
        didPressTab(self.tabButtons[self.selectedIdx])
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        
        let previousButtonIdx = self.selectedIdx
        self.selectedIdx = sender.tag
        
        self.tabButtons[previousButtonIdx!].isSelected = false
        sender.isSelected = true
        
        self.webview.loadRequest(self.htmlRequests[self.selectedIdx])
        
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
