//
//  ActivityIndicatorView.swift
//  mmReader
//
//  Created by 박종호 on 2016. 12. 23..
//  Copyright © 2016년 박종호. All rights reserved.
//

import UIKit

internal class ActivityIndicatorView: UIView {

    private var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect){
        
        super.init(frame: frame)
        
        self.activityIndicator = UIActivityIndicatorView()
        
        self.backgroundColor = UIColor.lightGray
        self.clipsToBounds = true
        self.alpha = 0.8
        
        // set activity indicator
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2 - 40)
        self.addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimating(){
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }
}
