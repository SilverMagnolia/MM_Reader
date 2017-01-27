//
//  MyLibraryController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 10. 17..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit
//import Foundation
//import FolioReaderKit

class MyLibraryController: UITableViewController{

    
    private var compactInfoOfBooks = [CompactInformationOfBook]()
    private let bookManager = BookManager.shared
    private var cellIndexToDelete: IndexPath?
    
    private var zzview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setCustomBackground()
        
        self.compactInfoOfBooks = self.bookManager.getBookInfoInDocument()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        // if there is a new epub downloaded, then reload tableview cells.
        if bookManager.isTableCellReloadNeeded! {
            
            self.compactInfoOfBooks.removeAll()
            self.compactInfoOfBooks = self.bookManager.getBookInfoInDocument()
            self.tableView.reloadData()
            
            bookManager.isTableCellReloadNeeded = false
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // #warning Incomplete implementation, return the number of rows
        return self.compactInfoOfBooks.count
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) ->String
    {
        return "삭제"
    }
    
    // view cells in table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCell
        
        // get the current row index of table view
        let row = indexPath.row
        
        // set title
        //cell.title.font = UIFont.systemFont(ofSize: 22)
        //cell.title.numberOfLines = 2
        cell.title.text = self.compactInfoOfBooks[row].title
        
        // set author
        //cell.authors.font = UIFont.systemFont(ofSize: 17)
        //cell.authors.textColor = UIColor.gray
        cell.authors.text =  self.compactInfoOfBooks[row].authors
        
        //set date
        //cell.publicationDate.font = UIFont.systemFont(ofSize: 17)
        //cell.publicationDate.textColor = UIColor.gray
        cell.publicationDate.text = self.compactInfoOfBooks[row].publicationDate
        
        //set cover image
        cell.coverImage.image = self.compactInfoOfBooks[row].cover
        
        return cell
    }
    
    // open epub reader
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let config = FolioReaderConfig()
        
        config.shouldHideNavigationOnTap = true
        config.scrollDirection = .horizontal
        
        FolioReader.presentReader(parentViewController: self, withEpubPath: self.bookManager.getBookPath(with: self.compactInfoOfBooks[indexPath.row].title!)
            , andConfig: config, shouldRemoveEpub: false)
    }
    
    
    // swipe to delete a book
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.cellIndexToDelete = indexPath
            
            confirmDelete(bookTitle: self.compactInfoOfBooks[indexPath.row].title!)
        }
    }
    
    private func confirmDelete(bookTitle: String) {
        
        // create alert controller and action
        let alert = UIAlertController(title: nil, message: "\(bookTitle)\n기기에서 완전히 삭제됩니다.", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "삭제", style: .destructive) {
            (alertAction) in
            
            if let indexPath = self.cellIndexToDelete{
                
                // save book title to be deleted temporarily.
                let bookTitle = self.compactInfoOfBooks[indexPath.row].title!
                
                // update table view
                self.tableView.beginUpdates()
                
                self.compactInfoOfBooks.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
                self.cellIndexToDelete = nil
                
                self.tableView.endUpdates()
                
                // delete the book with the 'bookTitle' from document permanently.
                if self.bookManager.deleteEpubInDocument(bookTitle: bookTitle){
                    print("\ndeleted all data assotiated with \(bookTitle)\n")
                } else {
                    print("\nfailed to delete \(bookTitle)\n")
                }
            }
        }
        
        let CancelAction = UIAlertAction(title: "취소", style: .cancel) {
            (alertAction) in
            self.cellIndexToDelete = nil
        }
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
