//
//  NotifyController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 2. 1..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

fileprivate struct NotifyCellDescriptor {
    
    var isExpandable: Bool!
    var isExpanded  : Bool!
    var isVisible   : Bool!
    
    var cellID      : String!
    var subject     : String?
    var url         : String?
    
    init(cellID: String) {
        
        self.cellID = cellID
        
        switch (cellID) {
            
        case subjectCellID:
            
            self.isExpandable = true
            self.isExpanded   = false
            self.isVisible    = true
            
        case webviewCellID:
            
            self.isExpandable = false
            self.isExpanded   = false
            self.isVisible    = false
            
        default:
            break
            
        }
    }
}

fileprivate let subjectCellID = "SubjectCell"
fileprivate let webviewCellID = "WebviewCell"

class NotifyController: UITableViewController {

    let urls = ["http:166.104.222.60/epub/The_Odyssey/The_Odyssey_여는글.html",
                "http:166.104.222.60/epub/The_Odyssey/The_Odyssey_목차.html",
                "http:166.104.222.60/epub/The_Odyssey/The_Odyssey_편집위원.html"]
    
    private var cellDescriptors: [NotifyCellDescriptor]!
    
    private var visibleRows         = [Int]()
    private var isNotifyShownOnView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadCellDescriptors()
        getIndicesOfVisibleRows()
        self.tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func loadCellDescriptors() {
        
        // 일단 임시로 하드코딩.
        // 서버로부터 [["subject", "url"]] 받아서, cellDescriptors 초기화.
        
        self.cellDescriptors = [NotifyCellDescriptor]()
        
        for i in 0...2 {
            
            var subjectDescriptor = NotifyCellDescriptor(cellID: subjectCellID
            )
            var webviewDescriptor = NotifyCellDescriptor(cellID: webviewCellID)
            
            subjectDescriptor.subject = "\(i)" + ")[공지]"
            webviewDescriptor.url = urls[i]
            
            self.cellDescriptors.append(subjectDescriptor)
            self.cellDescriptors.append(webviewDescriptor)
        }
    }
    
    private func getIndicesOfVisibleRows() {
        
        self.visibleRows.removeAll()
        
        for row in 0...(cellDescriptors.count - 1) {
            
            if cellDescriptors[row].isVisible as Bool {
                self.visibleRows.append(row)
            }
        }
    }
    
    private func getCellDescriptorForIndexPath(indexPath: IndexPath) -> NotifyCellDescriptor {
        
        let indexOfVisibleRow = self.visibleRows[indexPath.row]
        let cellDescriptor = self.cellDescriptors[indexOfVisibleRow]
        
        return cellDescriptor
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if cellDescriptors != nil {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.visibleRows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        
        let currentCellID = currentCellDescriptor.cellID
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellID!
            , for: indexPath) as! NotifyCell
        
        switch currentCellID! {
            
        case subjectCellID:
            
            cell.subjectLabel.text = currentCellDescriptor.subject
            
        case webviewCellID:
            
            if let url = URL(string: (currentCellDescriptor.url!)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            {
                cell.webview.loadRequest(URLRequest(url: url))
            }
            
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexOfTappedRow = self.visibleRows[indexPath.row]
        
        if self.isNotifyShownOnView &&
            (self.cellDescriptors[indexOfTappedRow].cellID == subjectCellID) {
            
            // collapse the webview and show the rest of subject cells
            
            self.cellDescriptors[indexOfTappedRow+1].isVisible = false

            for i in 0...(self.cellDescriptors.count - 1) {
                
                if (i % 2) == 0 {
                    self.cellDescriptors[i].isVisible = true
                }
            }
            
            self.isNotifyShownOnView = false
            
        } else if !self.isNotifyShownOnView {
            
            // show notify.
            
            for i in 0...(self.cellDescriptors.count - 1) {
                self.cellDescriptors[i].isVisible = false
            }
            
            self.cellDescriptors[indexOfTappedRow].isVisible = true
            self.cellDescriptors[indexOfTappedRow + 1].isVisible = true
            
            self.isNotifyShownOnView = true
        }
        
        getIndicesOfVisibleRows()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        
        switch (currentCellDescriptor.cellID) {
            
        case subjectCellID:
            return 60.0
            
        case webviewCellID:
            return (self.tableView.bounds.height - 60.0)
        
        default:
            return 60.0
        }
    }
}
