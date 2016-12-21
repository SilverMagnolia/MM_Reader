//
//  FullListController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 9..
//  Copyright © 2016년 박종호. All rights reserved.
//

import Foundation
import Alamofire

fileprivate struct BookInformation {
    var title: String?
    var authors: String?
    var publicationDate: String?
    var cover: UIImage?
    
    init(_ title: String, _ authors: String, _ date: String, _ cover: UIImage) {
        self.title = title
        self.authors = authors
        self.publicationDate = date
        self.cover = cover
    }
}

class FullListController: UITableViewController, URLSessionDelegate{
    
    private var numOfBooks:Int!
    private let url: URL! = URL(string: "http://166.104.222.60")
    private var unableToNetworkView = UIView()
    private var indicatorView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    private var compactBookInfo : [BookInformation]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        compactBookInfo = [BookInformation]()
    }
    
    private func showActivityIndicatorView() {

        // set indicator view
        indicatorView.frame = self.view.frame
        indicatorView.backgroundColor = UIColor.lightGray
        indicatorView.center = self.view.center
        indicatorView.clipsToBounds = true
        indicatorView.alpha = 0.8
        
        // set activity indicator
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: indicatorView.bounds.width / 2, y: indicatorView.bounds.height / 2 - 40)

        indicatorView.addSubview(activityIndicator)
        
        self.view.addSubview(indicatorView)
        activityIndicator.startAnimating()
    }
    
    private func hideIndicatorView() {
        activityIndicator.stopAnimating()
        indicatorView.removeFromSuperview()
    }
    
    private func createBookInformation() {
        
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
                
                let book = BookInformation(book["title"] ?? "",
                                           book["authors"] ?? "",
                                           book["date"] ?? "",
                                           img)
                self.compactBookInfo.append(book)
                
            } // end 1st for
            self.didLoadBookInfoFromServer()
            
        }) // end closure
    }
    
    private func didLoadBookInfoFromServer() {
        self.numOfBooks = self.compactBookInfo.count
        self.hideIndicatorView()
        self.tableView.reloadData()
    }
    
    private func showUnableToNetworkView() {
        let label = UILabel()
        let button = UIButton()
        
        unableToNetworkView.frame = self.view.frame
        unableToNetworkView.backgroundColor = UIColor.white
        unableToNetworkView.center = self.view.center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Try to connect to network"
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = UIColor.black
        button.addTarget(self, action: #selector(refreshButtonSelected(_:)), for: .touchUpInside)
        
        unableToNetworkView.addSubview(label)
        unableToNetworkView.addSubview(button)
        
        // constraint to label
        var constraint =
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: unableToNetworkView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -100)
        unableToNetworkView.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: unableToNetworkView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        unableToNetworkView.addConstraint(constraint)
        
        // constraint to button
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: unableToNetworkView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        unableToNetworkView.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: label, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20)
        unableToNetworkView.addConstraint(constraint)
        
        self.tableView.separatorStyle = .none
        self.view.addSubview(unableToNetworkView)
    }
    
    @objc private func refreshButtonSelected(_ sender : AnyObject) {
        unableToNetworkView.removeFromSuperview()
        showActivityIndicatorView()
        self.tableView.separatorStyle = .singleLine
        viewDidAppear(false)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.numOfBooks
    }
    
    
    // view cells in table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullListCell", for: indexPath) as! FullListCell

        // get the current row index of table view
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // check device's network status.
        if Reachability.connectedToNetwork() {
            createBookInformation()
        } else {
            showUnableToNetworkView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // clear table view's cells at each time it is viewed.
        self.numOfBooks = 0
        if compactBookInfo.count > 0 {
            self.compactBookInfo.removeAll()
            self.tableView.reloadData()
        }
        showActivityIndicatorView()
    }
}
