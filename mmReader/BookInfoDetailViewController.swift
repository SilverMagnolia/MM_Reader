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
                                    UITableViewDelegate, URLSessionDelegate
{

    private let downloadPath    = ""
    private let baseURL         = "http:166.104.222.60"
    private let cellID          = "DetailViewCell"
    private var cellTitleArr    = ["여는글", "목차", "편집위원소개"]
    
    private var kRowsCount      = 0
    private var cellHeights     = [CGFloat]()

    @IBOutlet weak var tableView            : UITableView!
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
    var sessionID           : String?
    
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
        //let urlstring = self.baseURL + "/POST_download.php"
        //self.sessionID = (NSUUID().uuidString)
        /*
        //let filepath = "Documents/local_teakettle"
        if let url = URL(string: urlstring) {
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "POST"
            urlRequest.httpBody = self.titleStr?.data(using: String.Encoding.utf8)
            
            let config = URLSessionConfiguration.background(withIdentifier: self.sessionID!)
           // let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            
            let task = session.downloadTask(with: urlRequest)
            task.resume()
        }*/
    }
    
    /*
    func urlSession(session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        
        var epubBasePath: String! = Bundle.main.path(forResource: nil, ofType: "epub", inDirectory: "epub source")
        epubBasePath = (epubBasePath as NSString).deletingLastPathComponent
        
        try! FileManager.default.moveItem(atPath: location.path, toPath: self.downloadPath)
    }*/


    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(C.CellHeight.close)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
