//
//  FullListCell.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 9..
//  Copyright © 2016년 박종호. All rights reserved.
//

import Foundation

class FullListCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var publicationDate: UILabel!
    @IBOutlet weak var authors: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
