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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if error != nil {
            print("an error occured while sending email")
        }
        
        controller.dismiss(animated: true, completion: nil)
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
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
