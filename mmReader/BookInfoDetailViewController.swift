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
    
    private let buttonTextArr   = [
                                    "beforeDownloading" : "Download",
                                    "afterDownloading"  : "보기"
                                  ]
    private let sessionID       = UUID().uuidString
    
    private var cellTitleArr        = ["여는글", "목차", "편집위원소개"]
    private var bookManager         = BookManager.shared
    private var kRowsCount          = 0
    private var cellHeights         = [CGFloat]()
    private var bookExists          = false
    private var isNetworkConnected  = false
    
    private lazy var popup: UnableToNetworkPopupView = {
        return UnableToNetworkPopupView(frame: self.view.frame)
     
    }()
    
    private lazy var confirmPopup: ConfirmMesssagePopupView = {
        return ConfirmMesssagePopupView(frame: self.view.frame)
    }()
    
    // for lower stack view
    @IBOutlet weak var tableView            : UITableView!
    
    // properties of upper stack view
    @IBOutlet weak var downloadButton       : DownloadProgressButton!
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
    
    private lazy var reachability: Reachability? = Reachability.shared
    private var downloadTask: URLSessionDownloadTask?
    private var isDownloadInProgress = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // fill upper subviews with text
        self.coverImageView.image       = self.cover ?? UIImage(named: "default")
        self.titleLabel.text            = self.titleStr ?? "title"
        self.navigationBar.title        = self.titleStr ?? "title"
        self.editorsLabel.text          = self.editorsStr ?? "editors"
        self.publicationDateLabel.text  = self.publicationDateStr ?? "date"
        self.emptyLabel.text            = ""
        
        self.downloadButton.setTitle(buttonTextArr["beforeDownloading"], for: .normal)
        self.downloadButton.backgroundColor = UIColor.lightGray
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(BookInfoDetailViewController.reachabilityDidchange(_:)),
                                               name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName),
                                               object: nil)
        _ = reachability?.startNotifier()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        checkReachability()
        
    }
    
    func checkReachability() {
        
        guard let r = reachability else { return }
        
        if r.isReachable  {
            
            // reachable
            print("connected to network")
            
            self.kRowsCount = 3
            createCellHeightsArray()
            self.tableView.reloadData()
            self.isNetworkConnected = true
            
        } else {
            
            // unreachable
            self.isNetworkConnected = false
            showPopup()
        }
    }
    
    func reachabilityDidchange(_ notification: Notification){
        checkReachability()
    }
    
    private func showPopup() {
        popup.center = self.view.center
        self.view.addSubview(popup)
    }
    
    override func viewWillLayoutSubviews() {
        
        if bookManager.checkIfTheBookExists(with: self.titleStr!) {
            
            self.downloadButton.bookIsAlreadyDownloaded()
            self.downloadButton.setTitle(buttonTextArr["afterDownloading"], for: .normal)
            self.bookExists = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectedDownloadButton(_ sender: AnyObject) {
        
        /*
         When the button is clicked, there are two options.
         
         First, if the book shown to this view has already downloaded and saved in user document,
         it will be opened in the epub reader.
         
         Second, if the book shown to this view has not downloaded yet,
         downloading the book will start and if successfully completed, 
         the method saving the book will be called.
         */
        
        if isDownloadInProgress {
            
            self.confirmPopup.center = self.view.center
            
            confirmPopup.addConrimAction {
                
                if self.isDownloadInProgress {
                    
                    self.downloadTask?.cancel()
                    self.downloadTask = nil
                
                    self.downloadButton.downloadCanceled()
                    self.isDownloadInProgress = false
                    self.downloadButton.setTitle(self.buttonTextArr["beforeDownloading"], for: .normal)
                }
                
                self.confirmPopup.removeFromSuperview()
            }
            
            confirmPopup.addCancelAction {
                
                self.confirmPopup.removeFromSuperview()
            }
            
            self.view.addSubview(confirmPopup)
            
            
            
        } else if self.isNetworkConnected {
            
            if self.bookExists {
            
                // the book already exists.
            
                let config = FolioReaderConfig()
            
                config.shouldHideNavigationOnTap = true
                config.scrollDirection = .horizontal
            
                FolioReader.presentReader(parentViewController: self, withEpubPath: self.bookManager.getBookPath(with: self.titleStr!)
                    , andConfig: config, shouldRemoveEpub: false)
                
            
            } else {
            
                // the book will be downloaded
                self.downloadButton.setColorToDownloadProgressArea(color: UIColor.brown.cgColor)
            
                var title = self.titleStr?.replacingOccurrences(of: " ", with: "_")
                title = title?.replacingOccurrences(of: "호", with: "")
            
                var urlstring = self.baseURL + "/epub/"
                urlstring = urlstring + title! + "/" + title! + ".epub"
            
                if let url = URL(string: urlstring) {
                
                    let urlRequest = URLRequest(url: url)
                
                    let downloadSession: URLSession = {
                        let config = URLSessionConfiguration.background(withIdentifier: self.sessionID)
                        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
                        return session
                    }()
                
                    self.downloadTask = downloadSession.downloadTask(with: urlRequest)
                    self.downloadTask?.resume()
                    self.isDownloadInProgress = true
                
                }// END IF
            } // END ELSE
            
        } else {
            
            showPopup()
            
        }
    }
    
    // during download
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        _ = self.downloadButton.setPortionOfDownloadProgressArea(totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
    
    // completed to download epub
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print("finished downloading.")
        
        if bookManager.addNewEpubToDocument(at: location.path, bookTitle: self.titleStr!) {
            
            self.downloadButton.setTitle("보기", for: .normal)
            
            self.bookExists = true
            self.isDownloadInProgress = false
            
            print("finished moving epub to sandbox")
        
        } else {
            print("failed to moving epub to sandbox")
        }
    }
    
    
    /**
     MARK: The methods below are for table view.
    */
    
    // Make url request for contents of folding cell
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
    
    // To initiate folding cell
    func createCellHeightsArray() {
        for _ in 0...kRowsCount {
            cellHeights.append(C.CellHeight.close)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //set folding cells of table view
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kRowsCount
    }
    
    
    // set folding cell configuration
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as FoldingCell = tableView.cellForRow(at: indexPath) else {
            return
        }
    
        var duration = 0.0
        if cellHeights[indexPath.row] == C.CellHeight.close { // open cell
            cellHeights[indexPath.row] = C.CellHeight.open
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            
            // close cell
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
