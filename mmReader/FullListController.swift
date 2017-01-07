//
//  FullListController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 9..
//  Copyright © 2016년 박종호. All rights reserved.
//

import Foundation
import Alamofire

class FullListController: UITableViewController, URLSessionDelegate{
    
    private let serverIP = "http://166.104.222.60"
    
    private var url                 : URL!
    private var numOfBooks          : Int!
    private var indicatorView       : ActivityIndicatorView!
    private var compactBookInfo     : [CompactInformationOfBook]!
    private var unableToNetworkView : UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.url = URL(string: self.serverIP)
        self.numOfBooks = 0
        self.indicatorView = ActivityIndicatorView(frame: self.view.frame)
        self.compactBookInfo = [CompactInformationOfBook]()

        /**
        the selected current view is FullListTableView when app is from inactive to active status.
        it should be checked to connect networking and, according to current status,
        update table view cell or show overray view again.
        */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FullListController.didBecomeActive),
                                               name: NSNotification.Name(rawValue: "didBecomeActiveOnFullList"),
                                               object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didBecomeActive()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.numOfBooks
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullListCell", for: indexPath) as! FullListCell
        let row = indexPath.row
        
        // set title
        cell.title.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.title.text = self.compactBookInfo[row].title
        
        // set authors
        cell.authors.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.authors.text = self.compactBookInfo[row].authors
        
        //set date
        cell.publicationDate.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.publicationDate.text = self.compactBookInfo[row].publicationDate
        
        //set cover image
        cell.coverImage.image = self.compactBookInfo[row].cover
        
        return cell
    }
    
    
    func didBecomeActive(){
        
        if Reachability.connectedToNetwork() {
            
            if unableToNetworkView != nil {
                hideUnableToNetworkView()
            }
            clearAndReloadData()
            
        } else if self.unableToNetworkView == nil {
            
            showUnableToNetworkView()
        }
    }
    
    
    private func clearAndReloadData() {
        
        showActivityIndicatorView()
        
        if self.compactBookInfo.count > 0 {
            self.numOfBooks = 0
            self.compactBookInfo.removeAll()
            self.tableView.reloadData()
        }
        
        createCompactInformationOfBook()
    }
    
    
    private func showActivityIndicatorView() {
        self.view.addSubview(self.indicatorView)
        self.indicatorView.startAnimating()
    }
    
    
    private func hideActivityIndicatorView() {
        self.indicatorView.stopAnimating()
        self.indicatorView.removeFromSuperview()
    }
    
    
    private func showUnableToNetworkView() {
        
        self.unableToNetworkView = UnableToNetworkView(frame: self.view.frame)
        self.unableToNetworkView?.center = self.view.center
        self.tableView.separatorStyle = .none
        self.view.addSubview((unableToNetworkView)!)
    }
    
    
    private func hideUnableToNetworkView() {
        self.unableToNetworkView!.removeFromSuperview()
        self.unableToNetworkView = nil
        self.tableView.separatorStyle = .singleLine
    }
    
    
    private func createCompactInformationOfBook() {
        
        /** 이 메소드 실행 중 네트워크 에러 발생하면 원인에 따라 적절한 팝업 메시지와 에러 처리 해야 함. */
        
        var bookInfo = [[String : String]]()
        var coverImages = [[String : String]]()
        
        let dispatchGroup = DispatchGroup()
        let queue = DispatchQueue(label: "com.dispatchGroup", attributes: .concurrent, target: .main)
        
        //request json to server
        dispatchGroup.enter()
        queue.async(group: dispatchGroup) {
            
            let urlRequest = self.url.appendingPathComponent("/phptest.php")
            Alamofire.request(urlRequest).responseJSON {
                response in
                    switch response.result {
                        
                    case .success :
                        print("\n\ngetting json data from server succeeded.\n\n")
                        
                        if let json = response.result.value,
                            let jsonConverted = json as? [[String:String]]
                        {
                            bookInfo = jsonConverted
                            
                            for obj in bookInfo{
                                
                                if let title = obj["title"]{
                                    print("\(title)")
                                }
                                
                                if let authors = obj["authors"]{
                                    print("\(authors)")
                                }
                                
                                if let date = obj["date"]{
                                    print("\(date)")
                                }
                            }
                        } // end if
                        
                    case .failure :
                        print("error")
                } // end switch
                dispatchGroup.leave()
            } // end closure
        }

        // request cover images to server
        dispatchGroup.enter()
        queue.async(group: dispatchGroup) {
            
            let urlRequest = self.url.appendingPathComponent("/requestImages.php")
            
            Alamofire.request(urlRequest).responseJSON {
                response in
                    switch response.result {
            
                    case .success :
                        
                        if let json = response.result.value,
                            let jsonConverted = json as? [[String:String]]
                        {
                            coverImages = jsonConverted
                        } // end if
                        
                        break
                        
                    case .failure:
                        
                        break
                } //end switch
                dispatchGroup.leave()
            } // end closure
        }
        
        //make book informations to be shown on view
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            
            // get book info from Array
            for book in bookInfo {
                
                var img : UIImage!
                var isFound = false
                
                // get element from cover array
                for covers in coverImages {
                    
                    // get key
                    for key in covers.keys {
                        
                        if book["title"] == key,
                            let imgData = Data(base64Encoded: covers[key]!, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)
                        {
                            img = UIImage(data: imgData)
                            isFound = true
                            break
                        } // end if
                    } // end 3rd for
                    
                    if isFound { break }
                    
                } // end 2nd for
                
                if !isFound {
                    img = UIImage(named: "smile")
                }
                
                let book = CompactInformationOfBook(book["title"] ?? "",
                                           book["authors"] ?? "",
                                           book["date"] ?? "",
                                           img)
                self.compactBookInfo.append(book)
                
            } // end 1st for
            self.didCompleteToLoadAllDataFromServer()
            
        }) // end closure
    }
    
    
    /**
     called when all request to server is completely responded.
     */
    private func didCompleteToLoadAllDataFromServer() {
        
        self.numOfBooks = self.compactBookInfo.count
        self.hideActivityIndicatorView()
        self.tableView.reloadData()
        
    }
    
    
    @objc private func refreshButtonSelected(_ sender : AnyObject) {
        
        if let view = unableToNetworkView {
            view.removeFromSuperview()
            self.unableToNetworkView = nil
        }
        
        showActivityIndicatorView()
        self.tableView.separatorStyle = .singleLine
        viewDidAppear(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ShowBookInfoDetails" {
            let detailViewController = segue.destination as! BookInfoDetailViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            let row = indexPath.row
            
            if let title = self.compactBookInfo[row].title{
                detailViewController.titleStr = title
            }
            
            if let editors = self.compactBookInfo[row].authors {
                detailViewController.editorsStr = editors
            }
            
            if let date = self.compactBookInfo[row].publicationDate {
                detailViewController.publicationDateStr = date
            }
            
            if let cover = self.compactBookInfo[row].cover {
                detailViewController.cover = cover
            }
        }
    }
}














