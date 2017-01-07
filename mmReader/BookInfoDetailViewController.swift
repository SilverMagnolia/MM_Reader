//
//  BookInfoDetailViewController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 26..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit
import Alamofire

fileprivate struct C {
    struct CellHeight {
        static let close: CGFloat = 40.0
        static let open : CGFloat = 139.0
    }
}

class BookInfoDetailViewController: UIViewController, UITableViewDataSource,
                                    UITableViewDelegate, URLSessionDownloadDelegate
{
    private let baseURL         = "http:166.104.222.60"
    private let cellID          = "DetailViewCell"
    private var cellTitleArr    = ["여는글", "목차", "편집위원소개"]
    
    private var bookManager     = BookManager.shared
    private var kRowsCount      = 0
    private var cellHeights     = [CGFloat]()
    
    private let sessionID       = UUID().uuidString
    
    // lower subview
    @IBOutlet weak var tableView            : UITableView!
    
    // upper subview
    @IBOutlet weak var coverImageView       : UIImageView!
    @IBOutlet weak var titleLabel           : UILabel!
    @IBOutlet weak var editorsLabel         : UILabel!
    @IBOutlet weak var publicationDateLabel : UILabel!
    @IBOutlet weak var emptyLabel           : UILabel!
    @IBOutlet weak var navigationBar        : UINavigationItem!
    
    var cover               : UIImage?
    var titleStr            : String?
    var editorsStr          : String?
    var publicationDateStr  : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // fill upper subviews with text
        self.coverImageView.image       = self.cover ?? UIImage(named: "default")
        self.titleLabel.text            = self.titleStr ?? "title"
        self.navigationBar.title        = self.titleStr ?? "title"
        self.editorsLabel.text          = self.editorsStr ?? "editors"
        self.publicationDateLabel.text  = self.publicationDateStr ?? "date"
        self.emptyLabel.text            = ""
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if( Reachability.connectedToNetwork() ){
            
            self.kRowsCount = 3
            createCellHeightsArray()
            self.tableView.reloadData()
            
        } else {
            // popup window
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectedDownloadButton(_ sender: AnyObject) {
        
        var title = self.titleStr?.replacingOccurrences(of: " ", with: "_")
        title = title?.replacingOccurrences(of: "호", with: "")
        
        var urlstring = self.baseURL + "/epub/"
        urlstring = urlstring + title! + "/" + title! + ".epub"
        
        if let url = URL(string: urlstring) {
            let urlRequest = URLRequest(url: url)
            
            let downloadSession: URLSession = {
                let config = URLSessionConfiguration.background(withIdentifier: self.sessionID)
                let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
                return session
            }()
            
            
            let task = downloadSession.downloadTask(with: urlRequest)
            task.resume()
        }
    }
    
    // completed to download epub
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("finished downloading.")
        
        if bookManager.addNewEpubToDocument(at: location.path, bookTitle: self.titleStr!) {
            print("finished moving epub to sandbox")
        } else {
            print("failed to moving epub to sandbox")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        print("\n")
        print("bytesWritten: \(bytesWritten)")
        print("totalBytesWritten: \(totalBytesWritten)")
        print("totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
    }
    
    
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(C.CellHeight.close)
        }
    }
    
    private func makeHtmlRequestURL(row : Int) -> String? {
        
        // make baseUrl/title/title_xx.html
        var title = self.titleStr?.replacingOccurrences(of: " ", with: "_")
        title = title?.replacingOccurrences(of: "호", with: "")
        
        var url = "\(self.baseURL)" + "/" + "epub" + "/" + "\(title!)" + "/" + "\(title!)" + "_" +
            "\(self.cellTitleArr[row])" + ".html"
        
        // encoding url
        url = url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        
        return url
    }
    
    /**
     set folding cells of table view
    */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kRowsCount
    }
    
    // set folding cell config
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath) else {
            return
        }
    
        var duration = 0.0
        if cellHeights[indexPath.row] == C.CellHeight.close { // open cell
            cellHeights[indexPath.row] = C.CellHeight.open
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = C.CellHeight.close
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { _ in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if case let cell as FoldingCell = cell {
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DetailViewCell
        let row = indexPath.row
        
        cell.title.text = self.cellTitleArr[row]
        
        if let urlStr = makeHtmlRequestURL(row : row),
            let urlInst = URL(string: urlStr) {
            
            let request = URLRequest(url: urlInst)
            cell.content.loadRequest(request)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension BookInfoDetailViewController: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            if let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                DispatchQueue.main.async(execute: {
                    completionHandler()
                })
            }
            
        }
    }
}
