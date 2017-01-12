//
//  UnableToNetworkView.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 23..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit

class UnableToNetworkView: UIView {

    let label_message   = "Try to connect to network"
    
    let view_background_color   = UIColor.white
    let button_color            = UIColor.black
    
    override init (frame: CGRect){
        
        super.init(frame: frame)

        let label = UILabel()
        
        self.backgroundColor = self.view_background_color
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = self.label_message
        
        self.addSubview(label)
        
        var constraint =
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -100)
        self.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        self.addConstraint(constraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
