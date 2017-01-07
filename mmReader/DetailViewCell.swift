//
//  DetailViewCell.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 27..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit

class DetailViewCell: FoldingCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UIWebView!
    
    override func awakeFromNib() {
        
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
	
