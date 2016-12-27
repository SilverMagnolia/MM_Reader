//
//  BookInfoDetailViewController.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 26..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit
import Alamofire

class BookInfoDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    private let baseURL         = "166.104.222.60/epub"
    private let cellID          = "DetailViewCell"
    private var cellTitleArr    = ["여는글", "목차", "편집위원소개"]
    
    @IBOutlet weak var tableView            : UITableView!
    @IBOutlet weak var coverImageView       : UIImageView!
    @IBOutlet weak var titleLabel           : UILabel!
    @IBOutlet weak var editorsLabel         : UILabel!
    @IBOutlet weak var publicationDateLabel : UILabel!
    @IBOutlet weak var emptyLabel           : UILabel!
    @IBOutlet weak var navigationBar        : UINavigationItem!
    
    var cover       : UIImage?
    var titleStr    : String?
    var editorsStr  : String?
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
        
    }
    
    private func getDataFromServer() {
    
    
    }
    
    
    /**
     set cells of table view
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DetailViewCell
        let row = indexPath.row
        
        cell.title.text = self.cellTitleArr[row]
        
        if let url = makeURL(row) {
            cell.webView.loadRequest(URLRequest(url: url))
        }
        */
        //return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

}
