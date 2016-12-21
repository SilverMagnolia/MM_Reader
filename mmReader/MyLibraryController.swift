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
import AEXML
import SSZipArchive

fileprivate struct CompactInformationOfBook {
    var title: String?
    var authors: [String]?
    var publicationDate: String?
    var cover: UIImage?
    var path: String?
    
    init(_ title: String, _ authors: [String], _ date: String, _ cover: UIImage, _ path: String) {
        self.title = title
        self.authors = authors
        self.publicationDate = date
        self.cover = cover
        self.path = path
    }
}

class MyLibraryController: UITableViewController, SSZipArchiveDelegate {

    private var compactInfoOfBooks = [CompactInformationOfBook]()
    private var numOfBooks: Int!
    private var epubBasePath: String!
    private var userDocumentDirPath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the path of epub source in Bundle
        self.epubBasePath = Bundle.main.path(forResource: nil, ofType: "epub", inDirectory: "epub source")
        self.epubBasePath = (epubBasePath as NSString).deletingLastPathComponent
        
        // set the path of document directory
        let fileMgr = FileManager.default
        self.userDocumentDirPath = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)[0].path
        
        // true: set number of books to .count
        // false: 0
        if getBookInfo() {
            self.numOfBooks = compactInfoOfBooks.count
        } else {
            self.numOfBooks = 0
        }
    }
    
    /**
     It initiates 'compactInfoOfBooks' array.
     If there's not any book, it returns false.
     calls: private func makeBookInfo()
     */
    private func getBookInfo() -> Bool {
        //get file list by searching the directory.
        let fileMgr = FileManager.default
        var filelist: [String]?
        
        do {
            filelist = try fileMgr.contentsOfDirectory(atPath: self.epubBasePath!)
            
            guard filelist != nil else { return false }
            
        }catch {
            print("FileManager.contentsOfDirectory(atPath: ) call error")
        }
        
        // extract each book's info from xml and assin the instances.
        for filename in filelist! {
            
            if let tmp = makeBookInfo(filename) {
                self.compactInfoOfBooks.append(tmp)
            } else {
                return false
            }
        }
        return true
    }
    
    private func makeBookInfo(_ filename: String) -> CompactInformationOfBook? {
        // set path
        let fullPathOfEpub: String! = (self.epubBasePath as NSString).appendingPathComponent(filename)
        var unzipPath: String! = (self.userDocumentDirPath as NSString).appendingPathComponent(filename)
        unzipPath = (unzipPath as NSString).deletingPathExtension
        
        // unzip epub to user document directory
        SSZipArchive.unzipFile(atPath: fullPathOfEpub, toDestination: unzipPath, delegate: self)
        
        // set path of content.opf
        let opfPath: String! = (unzipPath as NSString).appending("/OEBPS/content.opf")
        
        print("\nopfPath: \(opfPath)")
        
        // open opf file
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: opfPath))
            else { print("\nmakeBookInfo() an error occurred"); return nil }
        
        //extract title, authors, date and cover from xml.
        var title: String?
        var authors = [String]()
        var date: String?
        var cover: UIImage?
        
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            let tags: [AEXMLElement] = xmlDoc.root["metadata"].children
            
            //extract title, authors, date.
            for tag in tags {
                
                if tag.name == "dc:title" {
                    title = tag.value ?? ""
                }
                
                if tag.name == "dc:creator" {
                    authors.append(tag.value ?? "")
                }
                
                if tag.name == "dc:date" {
                    date = tag.value ?? ""
                }
            }
            
            // set path of resource directory
            var coverPath = (unzipPath as NSString).appendingPathComponent("/OEBPS/")
            
            // find path of cover image and make UIImage
            for item in xmlDoc.root["manifest"]["item"].all! {
                
                if item.attributes["id"] == "cover" {
                    
                    coverPath = (coverPath as NSString).appendingPathComponent(item.attributes["href"]!)
                    cover = UIImage(contentsOfFile: coverPath)
                    break
                }
            }

        }catch {
            print("AEXMLDocument(xml:) call error")
        }

        // create a book's compact info and return
        return CompactInformationOfBook(title!, authors, date!, cover!, unzipPath!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.numOfBooks
    }

    
    // view cells in table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCell
        
        // get the current row index of table view
        let row = indexPath.row
        
        // set title
        cell.title.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.title.text = self.compactInfoOfBooks[row].title
        
        //set author
        var authors: String! = ""
        cell.authors.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        for author in (self.compactInfoOfBooks[row].authors)! {
            authors.append(author)
            authors.append(" ")
        }
        
        cell.authors.text =  authors
        
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
        
        // See more at FolioReaderConfig.swift
        //        config.canChangeScrollDirection = false
        //        config.enableTTS = false
        //        config.allowSharing = false
        //        config.tintColor = UIColor.blueColor()
        //        config.toolBarTintColor = UIColor.redColor()
        //        config.toolBarBackgroundColor = UIColor.purpleColor()
        //        config.menuTextColor = UIColor.brownColor()
        //        config.menuBackgroundColor = UIColor.lightGrayColor()
        
        // Custom sharing quote background
        /*
        let customImageQuote = QuoteImage(withImage: UIImage(named: "demo-bg")!, alpha: 0.6, backgroundColor: UIColor.black)
        let customQuote = QuoteImage(withColor: UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0), alpha: 1.0, textColor: UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0))
 
        config.quoteCustomBackgrounds = [customImageQuote, customQuote]
        */
        
        FolioReader.presentReader(parentViewController: self, withEpubPath: self.compactInfoOfBooks[indexPath.row].path!, andConfig: config, shouldRemoveEpub: false)
    
    }
    
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
