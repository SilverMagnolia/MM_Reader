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
    
    // action handler
    private var cancelAction    : (() -> Void)?
    private var confirmAction   : (() -> Void)?
    
    override init (frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
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
        
        popupView.backgroundColor = UIColor.gray
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = UIColor.black.cgColor
        
        const = NSLayoutConstraint(item: popupView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 0.8, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.7, constant: 0)
        self.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.3, constant: 0)
        self.addConstraint(const)
        
        self.addSubview(popupView)
    }
    
    private func setPopupLabel() {
        
        var const: NSLayoutConstraint!
        
        popupLabel.translatesAutoresizingMaskIntoConstraints = false
        
        popupLabel.numberOfLines = 3
        popupLabel.textAlignment = NSTextAlignment.center
        popupLabel.textColor     = UIColor.darkGray
        popupLabel.text          = message
        
        const = NSLayoutConstraint(item: popupLabel, attribute: .centerX, relatedBy: .equal, toItem: popupView, attribute: .centerX, multiplier: 1, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: .centerY, relatedBy: .equal, toItem: popupView, attribute: .centerY, multiplier: 0.7, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: .width, relatedBy: .equal, toItem: popupView, attribute: .width, multiplier: 0.8, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: popupLabel, attribute: .height, relatedBy: .equal, toItem: popupView, attribute: .height, multiplier: 0.65, constant: 0)
        popupView.addConstraint(const)
        
        popupView.addSubview(popupLabel)
    }
    
    private func setButtons() {
        
        var const: NSLayoutConstraint!
        let backgroundColor = UIColor(red: 0.16, green: 0.21, blue: 0.33, alpha: 1)
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        //confirmButton
        confirmButton.setTitle("확인", for: .normal)
        confirmButton.titleLabel?.textColor = UIColor.black
        confirmButton.backgroundColor = backgroundColor

        const = NSLayoutConstraint(item: confirmButton, attribute: .leading, relatedBy: .equal, toItem: popupView, attribute: .leading, multiplier: 1.5, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: .bottom, relatedBy: .equal, toItem: popupView, attribute: .bottom, multiplier: 0.95, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: .width, relatedBy: .equal, toItem: popupView, attribute: .width, multiplier: 0.4, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: confirmButton, attribute: .height, relatedBy: .equal, toItem: popupView, attribute: .height, multiplier: 0.3, constant: 0)
        popupView.addConstraint(const)
        
        popupView.addSubview(confirmButton)
        
        confirmButton.addTarget(self, action: #selector(handleConfirmAction(sender:)), for: .touchUpInside)
        
        
        // cancelButton
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.textColor = UIColor.black
        cancelButton.backgroundColor = backgroundColor
        
        const = NSLayoutConstraint(item: cancelButton, attribute: .trailing, relatedBy: .equal, toItem: popupView, attribute: .trailing, multiplier: 0.95, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: popupView, attribute: .bottom, multiplier: 0.95, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: popupView, attribute: .width, multiplier: 0.4, constant: 0)
        popupView.addConstraint(const)
        
        const = NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: popupView, attribute: .height, multiplier: 0.3, constant: 0)
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
    
}
