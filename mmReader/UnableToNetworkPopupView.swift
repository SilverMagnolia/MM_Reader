//
//  UnableToNetworkPopupView.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 9..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

class UnableToNetworkPopupView: UIView {

    private let message = "네트워크 연결 상태를\n확인하십시오."
    
    private var popupView       = UIView()
    private var popupButton     = UIButton()
    private var popupLabel      = UILabel()
    
    override init (frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        
        setPopupView()
        setPopupLabel()
        setPopupButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPopupView() {
        
        var const: NSLayoutConstraint!
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        popupView.backgroundColor = UIColor.darkGray
        popupView.layer.borderWidth = 2
        popupView.layer.borderColor = UIColor.black.cgColor
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.7, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 0)
        self.addConstraint(const)
        
        self.addSubview(popupView)
    }
    
    private func setPopupLabel() {
    
        var const: NSLayoutConstraint!
        
        popupLabel.translatesAutoresizingMaskIntoConstraints = false
        
        popupLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        popupLabel.numberOfLines = 2
        popupLabel.textAlignment = NSTextAlignment.center
        popupLabel.textColor     = UIColor.black
        popupLabel.text          = message
        
        const = NSLayoutConstraint(item: popupLabel, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.centerY, multiplier: 0.6, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.width, multiplier: 0.7, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 0)
        popupView.addConstraint(const)
        
        popupButton.addTarget(self, action: #selector(buttonSelected(sender:)), for: .touchUpInside)
        
        popupView.addSubview(popupLabel)
    }
    
    private func setPopupButton() {
        
        var const: NSLayoutConstraint!
        
        popupButton.translatesAutoresizingMaskIntoConstraints = false
        
        popupButton.setTitle("확인", for: .normal)
        popupButton.titleLabel?.textColor = UIColor.black
        popupButton.backgroundColor = UIColor.brown
        
        const = NSLayoutConstraint(item: popupButton, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.bottom, multiplier: 0.7, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 0)
        popupView.addConstraint(const)
        
        popupButton.addTarget(self, action: #selector(buttonSelected(sender:)), for: .touchUpInside)
        
        popupView.addSubview(popupButton)
    }
    
    internal func buttonSelected (sender: UIButton) {
        
        self.removeFromSuperview()
        
    }
}
