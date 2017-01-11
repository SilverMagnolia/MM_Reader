//
//  ConfirmMessagePopupView.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 12..
//  Copyright © 2017년 박종호. All rights reserved.
//
//
import UIKit

class ConfirmMesssagePopupView: UIView {
    
    private let message = "다운로드를 취소하시겠습니까?\n'확인'을 누르면 취소됩니다."
    
    private var popupView       = UIView()
    private var cancelButton    = UIButton()
    private var confirmButton   = UIButton()
    private var popupLabel      = UILabel()
    
    private var cancelAction    : (() -> Void)?
    private var confirmAction   : (() -> Void)?
    
    override init (frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        //self.layer.opacity   = 0.8
        
        setPopupView()
        setPopupLabel()
        setButtons()
        
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
        //popupView.layer.opacity = 1.0
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 0.7, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 0)
        self.addConstraint(const)
        
        //self.layer.insertSublayer(popupView.layer, below: self.layer)
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
        
        popupView.addSubview(popupLabel)
    }
    
    private func setButtons() {
        
        var const: NSLayoutConstraint!
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.textColor = UIColor.black
        confirmButton.backgroundColor = UIColor.yellow
        
        const = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.bottom, multiplier: 0.7, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 0)
        popupView.addConstraint(const)
        
        popupView.addSubview(confirmButton)
        
        confirmButton.addTarget(self, action: #selector(handleConfirmAction(sender:)), for: .touchUpInside)
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.textColor = UIColor.black
        cancelButton.backgroundColor = UIColor.brown
        
        const = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.bottom, multiplier: 0.7, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: popupView, attribute: NSLayoutAttribute.height, multiplier: 0.3, constant: 0)
        popupView.addConstraint(const)
        
        cancelButton.addTarget(self, action: #selector(handleCancelAction(sender:)), for: .touchUpInside)
        
        popupView.addSubview(cancelButton)
    }
    
    internal func handleConfirmAction(sender: UIButton) {
        confirmAction!()
    }
    
    internal func handleCancelAction(sender: UIButton) {
        cancelAction!()
    }
    
    internal func addConrimAction(selector: @escaping () -> Void) {
        confirmAction = selector
    }
    
    internal func addCancelAction(selector: @escaping () -> Void) {
        cancelAction = selector
    }
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
}
