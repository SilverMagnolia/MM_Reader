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
    
    
    private var numOfBooks:Int = 0
    private let url: URL! = URL(string: "http://166.104.222.60")
    private var unableToNetworkView = UIView()
    private var indicatorView = UIView()
    private var activityIndicator = UIActivityIndicatorView()
    private var compactBookInfo = [CompactInformationOfBook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    private func checkConnectionToServer() -> Data?{
        
        func sendRequest(request: URLRequest) -> Data? {
            let session = URLSession.shared
            var dataReceived: Data = Data ()
            let sem = DispatchSemaphore(value: 0)
            
            let task = session.dataTask(with: request) {
                (data, response, error) in
                if error != nil{
                    print("Error -> \(error)")
                    return
                }
                
                dataReceived = data!
                sem.signal()
            }
            task.resume()
            
            // This line will wait until the semaphore has been signaled
            // which will be once the data task has completed
            sem.wait(timeout: .distantFuture)
            return dataReceived
        }
        
        return sendRequest(request: URLRequest(url: self.url.appendingPathComponent("/init.php")))
    }
    
    private func createCompactInformationOfBooks() {
        // create book's information by requsting to server.
        
        var bookInfo = [[String:String]]()
        var coverImages = [UIImage]()
        
        var sem = DispatchSemaphore(value: 0)
        
        // request json to server
        var urlRequest = self.url.appendingPathComponent("/phptest.php")
        Alamofire.request(urlRequest).responseJSON {
            
            response in switch response.result {
            
            case .success :
                print("\n\ngetting json data from server succeeded.\n\n")
   
                if let json = response.result.value,
                    let jsonConvertedToArr = json as? [[String:String]]
                {
                    
                    bookInfo = jsonConvertedToArr
                    sem.signal()
                    
                    /* debug
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
                    */
                    
                }
                break
            default :
                print("default")
            }
        }
        sem.wait(timeout: .distantFuture)
        
        
        sem = DispatchSemaphore(value: self.numOfBooks-1)
        // request cover images to server
        for i in 0...(self.numOfBooks-1){
            
            urlRequest = self.url.appendingPathComponent("/\(bookInfo[i]["title"]).jpg")
            Alamofire.request(urlRequest).responseData {
                response in
                
                if let data = response.result.value,
                    let cover = UIImage(data: data){
                    coverImages.append(cover)
                    sem.signal()
                }
                
            }
        }
        sem.wait(timeout: .distantFuture)
        
        // make book informations to be shown on view
        for i in 0...(self.numOfBooks-1) {
            var tempStrArr = [String]()
            tempStrArr.append(bookInfo[i]["authors"] ?? "")
            
            let book = CompactInformationOfBook(bookInfo[i]["title"] ?? "",
                                                tempStrArr,
                                                bookInfo[i]["date"] ?? "",
                                                coverImages[i], "")
         
            self.compactBookInfo.append(book)
        }
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
        self.tableView.separatorStyle = .singleLine
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
        
        //set author
        var authors: String! = ""
        cell.authors.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        
        for author in (self.compactBookInfo[row].authors)! {
            authors.append(author)
            authors.append(" ")
        }
        
        cell.authors.text =  authors
        
        //set date
        cell.publicationDate.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.publicationDate.text = self.compactBookInfo[row].publicationDate
        
        //set cover image
        cell.coverImage.image = self.compactBookInfo[row].cover

        
        return cell
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // waiting for loading data from server.
        showActivityIndicatorView()
        
        /** set the delay in which how long activity indicator will show on view.
         if needed, set the constant number.
         */
        /*
         let when = DispatchTime.now() + 3
         DispatchQueue.main.asyncAfter(deadline: when) {
         self.self.hideIndicatorView()
         self.showUnableToNetworkView()
         }
         */
        
        if let data = checkConnectionToServer(), let str = String(data: data, encoding: String.Encoding.utf8), let numOfBooks = Int(str){
            
            print("\n\nnumOfBooks: \(numOfBooks)\n\n")
            self.numOfBooks = numOfBooks
            createCompactInformationOfBooks()
            hideIndicatorView()
        } else {
            showUnableToNetworkView()
        }

    }
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    */
}
