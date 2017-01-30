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
    
    private var isViewFilledWithCells = false
    
    private var url                 : URL!
    private var numOfBooks          : Int!
    private var indicatorView       : ActivityIndicatorView!
    private var compactBookInfo     : [CompactInformationOfBook]!
    private var unableToNetworkView : UIView?
    
    private lazy var reachability: Reachability? = Reachability.shared
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        reachability?.stopNotifier()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setCustomBackground()
        
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
                                               selector: #selector(FullListController.reachabilityDidchange(_:)),
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numOfBooks
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullListCell", for: indexPath) as! FullListCell
        let row = indexPath.row
        
        cell.title.text = self.compactBookInfo[row].title
        cell.authors.text = self.compactBookInfo[row].authors
        cell.publicationDate.text = self.compactBookInfo[row].publicationDate
        cell.coverImage.image = self.compactBookInfo[row].cover
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "ShowBookDetails" {
            
            let detailViewController = segue.destination as! BookDetailsController
            
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
    
    func reachabilityDidchange(_ notification: Notification){
        checkReachability()
    }
    
    private func checkReachability() {
        
        let sema = DispatchSemaphore.init(value: 1)
        
        sema.wait()
        
        guard let r = reachability else { return }
        
        if r.isReachable  {
            
            // reachable
            
            if unableToNetworkView != nil {
                hideUnableToNetworkView()
            }
            
            clearAndReloadData()

            
        } else {
            
            // unreachable
            
            showUnableToNetworkView()
            isViewFilledWithCells = false
            
        }
        
        sema.signal()
        
    }
    
    private func clearAndReloadData() {
        
        
        //showActivityIndicatorView()
        
        
        if !isViewFilledWithCells{
            
            showActivityIndicatorView()
            
            if self.compactBookInfo.count > 0 {
                
                self.numOfBooks = 0
                self.compactBookInfo.removeAll()
                self.tableView.reloadData()
                
            }
        
            createCompactInformationOfBook()
            
            isViewFilledWithCells = true
        }
        
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
        
        if self.unableToNetworkView == nil {
            self.unableToNetworkView = UnableToNetworkView(frame: self.tableView.frame)
            self.unableToNetworkView?.center = self.tableView.center
            self.tableView.separatorStyle = .none
            self.view.addSubview((unableToNetworkView)!)
            addConstraintsToUnableToNetworkView()
        }
    }
    
    private func addConstraintsToUnableToNetworkView() {
        
        self.unableToNetworkView?.translatesAutoresizingMaskIntoConstraints = false
        
        var constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.tableView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.tableView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.tableView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)

        constraint = NSLayoutConstraint(item: self.unableToNetworkView!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.tableView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(constraint)

    }
    
    private func hideUnableToNetworkView() {
        
        if self.unableToNetworkView != nil {
            self.unableToNetworkView!.removeFromSuperview()
            self.unableToNetworkView = nil
            self.tableView.separatorStyle = .singleLine
        }
        
    }
    
    private func createCompactInformationOfBook() {
        
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
}














