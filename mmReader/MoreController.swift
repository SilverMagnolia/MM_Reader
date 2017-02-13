//
//  MoreController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 30..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit
import MessageUI

class MoreController: UITableViewController, MFMailComposeViewControllerDelegate {

    private let facebookURL = "https://www.facebook.com/hyumilmull/?fref=ts"
    private let email       = "excelsior_87@naver.com"
    private let emailBody   = "작성된 내용은 밀물 담당자에게 전달됩니다."
    private var isReachable: Bool!
    
    private lazy var reachability: Reachability? = Reachability.shared
    private lazy var alertVC: UIAlertController = {
        let VC = UIAlertController(title: "", message: "네트워크에 연결하십시오.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        VC.addAction(okAction)
        
        return VC
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FullListController.reachabilityDidchange(_:)),
                                               name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName),
                                               object: nil)
        _ = reachability?.startNotifier()
        
        self.isReachable = checkReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        var numberOfRows: Int!
        
        switch (section) {
            
        case 0 :
            numberOfRows = 1
        case 1:
            numberOfRows = 1
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 3
        case 4:
            numberOfRows = 1
        default:
            break
        }
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cellID: String! = tableView.cellForRow(at: indexPath)?.reuseIdentifier
        
        if (cellID != "ProgramInformationCell" && !self.isReachable) {
            
            self.present(self.alertVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        switch (cellID) {
            
        case "NotificationCell":
            break
            
        case "FacebookCell":
            UIApplication.shared.open(URL(string: facebookURL)!)
        
        case "BugReportCell", "FeedbackCell", "ItemReportCell":
            if !openEmail(cellID: cellID) {
                
                print("cannot open mail compose view.")
            }
            
        case "ProgramInformationCell":
            break
    
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func checkReachability() -> Bool {
    
        guard let r = reachability else { return false }
        
        if r.isReachable  {
            
            return true
            
        } else {
            
            return false
            
        }
    }
    
    private func openEmail(cellID: String) -> Bool{
        
        if !MFMailComposeViewController.canSendMail() {
            return false
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        composeVC.setToRecipients([self.email])
        composeVC.setMessageBody(self.emailBody, isHTML: false)
        
        switch (cellID) {
            
        case "BugReportCell":
            composeVC.setSubject("[버그신고]")
            
        case "FeedbackCell":
            composeVC.setSubject("[건의사항]")
            
        case "ItemReportCell":
            composeVC.setSubject("[제보]")
            
        default:
            break
        }
        
        if !MFMailComposeViewController.canSendMail() {
            return false
        }
        
        self.present(composeVC, animated: true, completion: nil)
        
        return true
    }
    
    func reachabilityDidchange(_ notification: Notification){
        self.isReachable = checkReachability()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if error != nil {
            print("an error occured while sending email")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    

    
    
}
