//
//  BookDetailsController.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 30..
//  Copyright © 2017년 박종호. All rights reserved.
//


import UIKit
import Alamofire


class BookDetailsController: UIViewController, UITableViewDataSource,
    UITableViewDelegate, URLSessionDownloadDelegate
{
    private let baseURL             = "http:166.104.222.60"
    private let cellID              = "BookDetailsCell"
    private let cellTitleArr        = ["여는글", "목차", "편집위원"]
    private let buttonTextArr       = [
        "beforeDownloading" : "다운로드",
        "afterDownloading"  : "보기"
    ]
    private let sessionID           = UUID().uuidString
    
    private var bookManager         = BookManager.shared
    private var reachability        = Reachability.shared
    
    private var bookExists           = false
    private var isNetworkConnected   = false
    private var isDownloadInProgress = false
    
    private var downloadTask: URLSessionDownloadTask?
    
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
    @IBOutlet weak var navigationBar        : UINavigationItem!
    
    var cover               : UIImage?
    var titleStr            : String?
    var editorsStr          : String?
    var publicationDateStr  : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
        // fill upper subviews with text
        self.coverImageView.image       = self.cover ?? UIImage(named: "default")
        self.titleLabel.text            = self.titleStr ?? "title"
        self.navigationBar.title        = self.titleStr ?? "title"
        self.editorsLabel.text          = self.editorsStr ?? "editors"
        self.publicationDateLabel.text  = self.publicationDateStr ?? "date"
        
        
        self.downloadButton.setTitle(buttonTextArr["beforeDownloading"], for: .normal)
        self.downloadButton.backgroundColor = UIColor(red: 0.30, green: 0.39, blue: 0.55, alpha: 1.0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(BookDetailsController.reachabilityDidchange(_:)),
                                               name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName),
                                               object: nil)
        _ = reachability?.startNotifier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        checkReachability()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        
        if bookManager.checkIfTheBookExists(with: self.titleStr!) {
            
            self.downloadButton.bookIsAlreadyDownloaded()
            self.downloadButton.setTitle(buttonTextArr["afterDownloading"], for: .normal)
            self.bookExists = true
        }
        
        navigationBar.backBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func checkReachability() {
        
        guard let r = reachability else { return }
        
        if r.isReachable  {
            
            // reachable
            print("connected to network")
            
            self.tableView.reloadData()
            self.isNetworkConnected = true
            
        } else {
            
            // unreachable
            self.isNetworkConnected = false
            showUnableToNetworkPopup()
        }
    }
    
    private func showUnableToNetworkPopup() {
        popup.center = self.view.center
        self.view.addSubview(popup)
    }
    
    private func showConfirmPopup() {
        
        // add target action to confirm button.
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
        
        // add target action to cancel button.
        confirmPopup.addCancelAction {
            
            self.confirmPopup.removeFromSuperview()
        }
        
        // show confirm popup view.
        self.confirmPopup.center = self.view.center
        self.view.addSubview(confirmPopup)
    }
    
    
    /**
     When the button is clicked, there are three options.
     
     First, if the book shown to this view has already downloaded and saved in user document,
     it will be opened in the epub reader.
     
     Second, if the book shown to this view has not downloaded yet,
     downloading the book will start and if successfully completed,
     the method in charge of saving the book will be called.
     
     Thrid, if download is in progress, confirm cancelation popup view
     should be shown above the root view.
     */
    @IBAction func selectedDownloadButton(_ sender: AnyObject) {
        
        if self.isDownloadInProgress {
            
            // download is in progress.
            
            showConfirmPopup()
            
        } else if self.isNetworkConnected {
            
            // network has been connected successfully.
            
            if self.bookExists {
                
                // the book already exists.
                
                let config = FolioReaderConfig()
                
                config.shouldHideNavigationOnTap = true
                config.scrollDirection = .horizontal
                
                FolioReader.presentReader(parentViewController: self, withEpubPath: self.bookManager.getBookPath(with: self.titleStr!)
                    , andConfig: config, shouldRemoveEpub: false)
                
                
            } else {
                
                // the book will be downloaded
                
                
                // set manually the color of download progress area of the download button.
                // if not set, the default color is brown.
                self.downloadButton.setColorToDownloadProgressArea(color: UIColor(red: 0.16, green: 0.21, blue: 0.33, alpha: 1).cgColor)
                
                // url, session, download task
                var title = self.titleStr?.replacingOccurrences(of: " ", with: "_")
                title = title?.replacingOccurrences(of: "호", with: "")
                
                var urlstring = self.baseURL + "/epub/"
                urlstring = urlstring + title! + "/" + title! + ".epub"
                
                if let url = URL(string: urlstring) {
                    
                    let urlRequest = URLRequest(url: url)
                    
                    // background download session.
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
            
            // network is unavailable.
            
            showUnableToNetworkPopup()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BookDetailsCell
        
        let row = indexPath.row
        
        cell.label.text = self.cellTitleArr[row]
        
        return cell
    }
    
    // the status of network was just changed.
    func reachabilityDidchange(_ notification: Notification){
        checkReachability()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowBookDetailsTabBar" {
            
            let bookDetailsTabBarController = segue.destination as! BookDetailsCustomTabBarController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            let row = indexPath.row
            
            // selected idx
            bookDetailsTabBarController.selectedIdx = row

            // url requests which will be loaded on webview
            var urlRequestArr = [URLRequest]()
            for i in 0...2 {
                
                if let urlStr = makeHtmlRequestURL(row: i),
                    let urlInst = URL(string: urlStr) {
                    
                    let request = URLRequest(url: urlInst)
                    urlRequestArr.append(request)
                }
            }
            
            bookDetailsTabBarController.htmlRequests = urlRequestArr
            bookDetailsTabBarController.bookTitle = self.titleStr
        }
    }
}



extension BookDetailsController: URLSessionDelegate {
    
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
