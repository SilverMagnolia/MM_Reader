//
//  DownloadProgressButton.swift
//  mmReader
//
//  Created by 박종호 on 2017. 1. 7..
//  Copyright © 2017년 박종호. All rights reserved.
//

import UIKit

internal class DownloadProgressButton: UIButton
{
    private var downloadProgressArea, normalArea: CALayer!
    private var portionOfDownloadProgressArea: CGFloat = 0.0
    
    
    override func draw(_ rect: CGRect) {
        
        // set default
        let (slice, remainder) = rect.divided(atDistance: self.bounds.size.width * self.portionOfDownloadProgressArea, from: .minXEdge)
        
        // create background layer
        downloadProgressArea = CALayer()
        normalArea = CALayer()
        
        // assign portion of each layers
        downloadProgressArea.frame = slice
        normalArea.frame = remainder
        
        // set colors to each layers
        downloadProgressArea.backgroundColor = UIColor.darkGray.cgColor
        normalArea.backgroundColor = UIColor.gray.cgColor
        
        // insert sublayers below self.layer
        self.layer.insertSublayer(downloadProgressArea, below: self.layer)
        self.layer.insertSublayer(normalArea, below: self.layer)
    }
    
    /**
     update portion of each areas
    */
    private func adjustPropertiesToSublayers() {
        self.layoutIfNeeded()
        
        let (slice, remainder) =
            self.bounds.divided(atDistance: self.bounds.size.width * self.portionOfDownloadProgressArea, from: .minXEdge)
        
        downloadProgressArea.frame = slice
        normalArea.frame = remainder
     
        self.layoutIfNeeded()
    }
    
    internal func setPortionOfDownloadProgressArea(by portion: CGFloat) -> Bool{
        
        if portion > 1.0 || portion < 0  {
            print("portion value must be smaller than 1 and grater than 0.")
            
            return false
        }
        
        self.portionOfDownloadProgressArea = portion
        adjustPropertiesToSublayers()
        
        return true
    }
    
    internal func setColorToDownloadProgressArea(color: CGColor) {
        
        self.layoutIfNeeded()
        self.downloadProgressArea.backgroundColor = color
        self.layoutIfNeeded()
        
    }
    
    internal func setColorTonormalArea(color: CGColor) {
        
        self.layoutIfNeeded()
        self.normalArea.backgroundColor = color
        self.layoutIfNeeded()
        
    }
    
}


