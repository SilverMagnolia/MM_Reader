//
//  NotifyCell.swift
//  mmReader
//
//  Created by 박종호 on 2017. 2. 1..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class NotifyCell: UITableViewCell {

    
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var subjectLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
