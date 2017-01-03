//
//  MyLibraryController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 10. 17..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit
import Foundation
import FolioReaderKit

class MyLibraryController: UITableViewController{

    private var compactInfoOfBooks = [CompactInformationOfBook]()
    private let bookManager = BookManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.compactInfoOfBooks = self.bookManager.getBookInfoInDocument()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        // if there is a new epub downloaded, then reload tableview cells.
        if bookManager.isThereANewEpub! {
            
            self.compactInfoOfBooks.removeAll()
            self.compactInfoOfBooks = self.bookManager.getBookInfoInDocument()
            self.tableView.reloadData()
            
            bookManager.isThereANewEpub = false
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

    
    // view cells in table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCell
        
        // get the current row index of table view
        let row = indexPath.row
        
        // set title
        cell.title.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.title.text = self.compactInfoOfBooks[row].title
        
        // set author
        cell.authors.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.authors.text =  self.compactInfoOfBooks[row].authors
        
        //set date
        cell.publicationDate.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
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
}
