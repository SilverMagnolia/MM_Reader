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
    private var overlayView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if checkConnectionToServer() {
            
            
        }
        else {
            // show a message "connect to network"
            showOverlayView()
        }
    }
    
    
    
    private func checkConnectionToServer() -> Bool{
        var isNetworkConnected = false
        
        let urlRequest = self.url.appendingPathComponent("/init.php")
        Alamofire.request(urlRequest).responseData(completionHandler: {
            response in
            debugPrint("All Response Info: \(response)")
            
            if let data = response.result.value {
                let str = String(data: data, encoding: String.Encoding.utf8)
                self.numOfBooks = Int(str!)!
                if(self.numOfBooks > 0 && self.numOfBooks < 60){
                    isNetworkConnected = true
                }
            }
        })
        return isNetworkConnected
    }
    
    private func showOverlayView() {
        let label = UILabel()
        let button = UIButton()
        
        overlayView.frame = self.view.frame
        overlayView.backgroundColor = UIColor.white
        overlayView.center = self.view.center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Try to connect to network"
        button.setTitle("Refresh", for: .normal)
        button.backgroundColor = UIColor.black
        button.addTarget(self, action: #selector(selected(_:)), for: .touchUpInside)
        
        overlayView.addSubview(label)
        overlayView.addSubview(button)
        
        // constraint to label
        var constraint =
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: overlayView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -100)
        overlayView.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: overlayView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        overlayView.addConstraint(constraint)
        
        // constraint to button
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: overlayView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        overlayView.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: label, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20)
        overlayView.addConstraint(constraint)
        
        self.tableView.separatorStyle = .none
        self.view.addSubview(overlayView)
    }
    
    @objc private func selected(_ sender : AnyObject) {
        
        overlayView.removeFromSuperview()
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

        var urlRequest = self.url.appendingPathComponent("/1.jpg")
        Alamofire.request(urlRequest).responseData(completionHandler: {
            response in
            debugPrint("All Response Info: \(response)")
            
            
            if let data = response.result.value {
                cell.coverImage.image = UIImage(data: data)
            }
        })
        
        urlRequest = self.url.appendingPathComponent("/phptest.php")
        Alamofire.request(urlRequest).responseJSON(completionHandler: {
            response in switch response.result {
            case .success(let JSON):
                debugPrint("All Response Info: \(response)")
                
                let response = JSON as! NSDictionary
                
                cell.title.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                cell.authors.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
                cell.publicationDate.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)

                
                cell.title.text = response.object(forKey: "title") as! String?
                cell.authors.text = response.object(forKey: "authors") as! String?
                cell.publicationDate.text = response.object(forKey: "date") as! String?
                
                
            case .failure(let error):
                print("failed with error: \(error)")
            }
            
        })
        return cell
 
    }
 
    
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    */
}
