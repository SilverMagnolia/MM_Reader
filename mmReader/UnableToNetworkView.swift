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
    let button_message  = "Refresh"
    
    let view_background_color   = UIColor.white
    let button_color            = UIColor.black
    
    
    override init (frame: CGRect){
        
        super.init(frame: frame)

        let label = UILabel()
        let button = UIButton()
        
        self.backgroundColor = self.view_background_color
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = self.label_message
        button.setTitle(button_message, for: .normal)
        button.backgroundColor = button_color
        
        //button.addTarget(self, action: #selector(refreshButtonSelected(_:)), for: .touchUpInside)
        
        self.addSubview(label)
        self.addSubview(button)
        
        // constraint to label
        var constraint =
            NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: -100)
        self.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        self.addConstraint(constraint)
        
        // constraint to button
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0)
        self.addConstraint(constraint)
        
        constraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: label, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 20)
        self.addConstraint(constraint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
