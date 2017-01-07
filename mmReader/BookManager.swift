//
//  FileManagement.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 29..
//  Copyright © 2016년 박종호. All rights reserved.
//

import Foundation
import AEXML
import SSZipArchive
import FMDB


internal struct CompactInformationOfBook{
    
    var title: String?
    var authors: String?
    var publicationDate: String?
    var coverPath: String?
    var cover: UIImage?
    
    init(_ title: String, _ authors: String, _ date: String,
         _ coverPath: String,_ cover: UIImage ){
        self.title = title
        self.authors = authors
        self.publicationDate = date
        self.coverPath = coverPath
        self.cover = cover
    }
    
    init(_ title: String, _ authors: String, _ date: String, _ cover: UIImage ){
        self.title = title
        self.authors = authors
        self.publicationDate = date
        self.cover = cover
    }
}

class BookManager {
    
    static let shared = BookManager()
    static var appDocumentPath         : String!
    
    private let dbFileName = "book_info.sqlite"
    
    private var epubBasePathInBundle    : String!
    private var dbPath                  : String!
    private var database                : FMDatabase!
    
    internal var isTableCellReloadNeeded        : Bool!
    
    init(){
        
        self.isTableCellReloadNeeded = false
        
        // initialize directory paths
        BookManager.appDocumentPath =
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        self.epubBasePathInBundle = Bundle.main.path(forResource: nil, ofType: "epub", inDirectory: "epub source")
        self.epubBasePathInBundle = (epubBasePathInBundle as NSString).deletingLastPathComponent
        
        self.dbPath = (BookManager.appDocumentPath as NSString).appendingPathComponent(self.dbFileName)
        
        // check if database file already exists in "/document",
        // then make the file and create table if not exist.
        if !(FileManager.default.fileExists(atPath: self.dbPath)){
            
            if createNewDB() {
                
                if !(moveEpubToDocument()) {
                    print("\nfailed to move epubs to user document directory.\n")
                }
                
            } else {
                print("\nfailed to create new DB\n")
            }
            
            
        } else {
            
            if !(openDB()) { print("\nfailed to open DB")}
            
        }
        
        showAllTupleInDB()
    }
    
    private func openDB() -> Bool{
        
        // new database
        guard let db = FMDatabase(path: URL(string: self.dbPath)?.path) else {
            print("unable to create database")
            return false
        }
        
        self.database = db
        
        guard self.database.open() else {
            print("Unable to open database")
            return false
        }
        return true
    }
    
    private func createNewDB() -> Bool{
        
        if !openDB(){ return false }
        
        // new table named 'book_info'
        let createTableStr = "create table book_info(title text, editors text, publicationDate text, coverPath text)"
        
        if !self.database.executeUpdate(createTableStr, withArgumentsIn: nil){
            print(database.lastError())
            return false
        }
        return true
    }
    
    private func insertBookInfoToDB (
        title: String, editors: String, date: String, coverPath: String) -> Bool{
        
        let statement = "insert into book_info (title, editors, publicationDate, coverPath) values (?, ?, ?, ?)"
    
        if !self.database.executeUpdate(statement, withArgumentsIn: [title, editors, date, coverPath]) {
            print(database.lastError())
            return false
        }
        return true
    }
    
    private func moveEpubToDocument() -> Bool {
    
        var filelist: [String]?
        
        do {
            
            //get the epub list in bundle
            filelist = try FileManager.default.contentsOfDirectory(atPath: self.epubBasePathInBundle)
            
            guard filelist != nil else { return false }
            
        }catch {
            print("FileManager.contentsOfDirectory(atPath: ) call error")
        }
        
        // extract each book's info from xml and assin the instances.
        for filename in filelist! {
            
            if let bookInfo = getBookInfo(filename) {
                
                if !insertBookInfoToDB(title: bookInfo.title, editors: bookInfo.editors,
                                       date: bookInfo.date, coverPath: bookInfo.coverPath) {
                    
                    print("failed to insert book infomation to DB")
                    return false
                
                }
                
            } else {
                
                return false
            }
        }
        return true
    }
    
    private func getBookInfo(_ filename: String)
        ->(title:String, editors:String, date:String, coverPath:String)?{
        
        // set path
        let fullPathOfEpub: String! = (self.epubBasePathInBundle as NSString).appendingPathComponent(filename)
        var unzipPath: String! = (BookManager.appDocumentPath as NSString).appendingPathComponent(filename)
        unzipPath = (unzipPath as NSString).deletingPathExtension
        
        // unzip epub to user document directory
        if !(unzip(atPath: fullPathOfEpub, toDestination: unzipPath)) {
            print("\nunzip failed\n")
        }
        
        // set path of content.opf
        let opfPath: String! = (unzipPath as NSString).appending("/OEBPS/content.opf")
        
        print("\nopfPath: \(opfPath)")
        
        // open opf file
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: opfPath))
            else { print("\nmakeBookInfo() an error occurred"); return nil }
        
        //extract title, authors, date and cover from xml.
        var title: String?
        var editorsArr = [String]()
        var date: String?
        var coverPath: String?
        
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            let tags: [AEXMLElement] = xmlDoc.root["metadata"].children
            
            //extract title, authors, date.
            for tag in tags {
                
                if tag.name == "dc:title" {
                    title = tag.value ?? ""
                }
                
                if tag.name == "dc:creator" {
                    editorsArr.append(tag.value ?? "")

                }
                
                if tag.name == "dc:date" {
                    date = tag.value ?? ""
                }
            }
            
            // set path of resource directory
            coverPath = (unzipPath as NSString).lastPathComponent
            coverPath = "/"+coverPath!+"/OEBPS"

            // find path of cover image
            for item in xmlDoc.root["manifest"]["item"].all! {
                
                if item.attributes["id"] == "cover" {
                    
                    coverPath = (coverPath! as NSString).appendingPathComponent(item.attributes["href"]!)
                    break
                }
            }
            
        }catch {
            print("AEXMLDocument(xml:) call error")
        }
        
        // sum editorsArr into one string
        var editors = editorsArr[0]
            
        if editorsArr.count > 1 {
            for i in 1...editorsArr.count-1 {
                editors = "\(editors)"+", "+"\(editorsArr[i])"
            }
        }
            
        // create a book's compact info and return
        return (title!, editors, date!, coverPath!)
    }
    
    private func unzip(atPath fullPathOfEpub: String, toDestination unzipPath: String) -> Bool{
        SSZipArchive.unzipFile(atPath: fullPathOfEpub, toDestination: unzipPath, delegate: nil)
        
        if FileManager.default.fileExists(atPath: unzipPath) {
            return true
        }
        return false
    }
    
    internal func getBookInfoInDocument() -> [CompactInformationOfBook]{
        
        let statement = "select * from book_info"
        var bookInfoArr = [CompactInformationOfBook]()
        
        let rs = database.executeQuery(statement, withArgumentsIn: nil)
        while (rs?.next())! {
            
            let title = rs?.string(forColumn: "title")
            let editors = rs?.string(forColumn: "editors")
            let date = rs?.string(forColumn: "publicationDate")
            //let imgURL = "\(self.appDocumentPath)"+"\(rs?.string(forColumn: "coverPath")!)"
            
            let imgURL = URL(string: BookManager.appDocumentPath)?.appendingPathComponent((rs?.string(forColumn: "coverPath"))!)
            let cover = UIImage(contentsOfFile: imgURL!.path)
            
            let bookInfo = CompactInformationOfBook(title!, editors!, date!, cover!)
            
            bookInfoArr.append(bookInfo)
        }
        return bookInfoArr
    }
    
    internal func getBookPath(with title: String) -> String {
        
        let path = (BookManager.appDocumentPath as NSString).appendingPathComponent(title)
        return path
    }
    
    internal func addNewEpubToDocument(at srcPath: String, bookTitle: String) -> Bool{
        
        var epubDestPath = BookManager.appDocumentPath
        epubDestPath = (epubDestPath! as NSString).appendingPathComponent(bookTitle)
        
        if(unzip(atPath: srcPath, toDestination: epubDestPath!)) {
            
            if let bookInfo = getBookInfo(bookTitle) {
                
                if !insertBookInfoToDB(title: bookInfo.title, editors: bookInfo.editors,
                                       date: bookInfo.date, coverPath: bookInfo.coverPath) {
                    
                    print("failed to insert book infomation to DB")
                    return false
                    
                } // END IF
                
                self.isTableCellReloadNeeded = true
                showAllTupleInDB()
                return true
                
            } // END IF
        } // END IF
        
        return false
    }
    
    private func showAllTupleInDB() {
        
        let rs = database.executeQuery("select * from book_info", withArgumentsIn: nil)
        
        while (rs?.next())! {
            if let title = rs?.string(forColumn: "title"),
                let editors = rs?.string(forColumn: "editors"),
                let publicationDate = rs?.string(forColumn: "publicationDate"){
                
                print("\ntitle = \(title); \neditors = \(editors); \ndate = \(publicationDate)")
            }
        }
    }
    
    internal func deleteEpubInDocument(bookTitle: String) -> Bool {
    
        // delete the book from user document
        let bookPathTobeDeleted = (BookManager.appDocumentPath as NSString).appendingPathComponent(bookTitle)
        
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: bookPathTobeDeleted, isDirectory: true))
            
            print("\ndeleted \(bookTitle) from document\n")
        } catch(let error){
            print("\(error)")
        }
        
        
        // delete the book with 'bookTitle' from DB
        let statement = "delete from book_info where title = ?"
        var title = [String]()
        title.append(bookTitle)
    
        if !self.database.executeUpdate(statement, withArgumentsIn: title) {
            print(database.lastError())
            return false
        }
        print("\ndeleted \(bookTitle) from DB\n")
        
        showAllTupleInDB()
        return true
        
    }
}
