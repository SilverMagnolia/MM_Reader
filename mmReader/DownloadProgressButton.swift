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
    private var downloadingMessage              : String?
    private var portionOfDownloadProgressArea   : CGFloat = 0.0
    
    private var downloadProgressArea            = CALayer()
    private var normalArea                      = CALayer()
    private var DBAreaColor                     = UIColor.brown.cgColor
    
    override func draw(_ rect: CGRect) {
        
        var eachPortion: (slice: CGRect, remainder: CGRect)!

        // the portion of download progress area equals to zero by default
        eachPortion = rect.divided(atDistance: self.bounds.size.width * self.portionOfDownloadProgressArea, from: .minXEdge)
        
        // assign portion of each layers
        downloadProgressArea.frame = eachPortion.0
        normalArea.frame = eachPortion.1
        
        downloadProgressArea.backgroundColor = self.DBAreaColor
        
        // insert sublayers below self.layer
        self.layer.insertSublayer(downloadProgressArea, below: self.titleLabel?.layer)
        self.layer.insertSublayer(normalArea, below: self.titleLabel?.layer)
    }

    /**
     update portion of each areas and draw them.
    */
    private func adjustPropertiesToSublayersDuringDownload() {
        
        self.layoutIfNeeded()
        
        let (slice, remainder) =
            self.bounds.divided(atDistance: self.bounds.size.width * self.portionOfDownloadProgressArea, from: .minXEdge)
        
        downloadProgressArea.frame = slice
        normalArea.frame = remainder
     
        
        if let message = self.downloadingMessage {
            super.setTitle("\(message)", for: .normal)
        } else {
            super.setTitle("Downloading", for: .normal)
        }
        
        self.layoutIfNeeded()
        
    }
    
    private func calculatePercentage(lhs: Int64, rhs: Int64) -> CGFloat {
        
        let dividend = CGFloat(lhs)
        let divisor  = CGFloat(rhs)
        let quotient = dividend/divisor
        
        return quotient
    }
    
    internal func setPortionOfDownloadProgressArea(totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Bool{
        
        // calculate percentage
        let portion = calculatePercentage(lhs: totalBytesWritten, rhs: totalBytesExpectedToWrite)
        
        // check range of portion
        if portion > 1.0 || portion < 0  {
            print("Portion value must range from 0 to 100.\ncurrent portion: \(portion)")
            
            return false
        }
        
        self.portionOfDownloadProgressArea = portion
        adjustPropertiesToSublayersDuringDownload()
        
        return true
    }
    
    internal func bookIsAlreadyDownloaded() {
        self.portionOfDownloadProgressArea = 100
    }
    
    /**
     set color to each areas
    */
    internal func setColorToDownloadProgressArea(color: CGColor) {
        self.downloadProgressArea.backgroundColor = color
    }

    /**
     set custom text on the button while downloading.
     default is "Downloading."
     */
    internal func setMessageDuringDownload(string message: String) {
        super.titleLabel?.text = message
    }
    
    internal func downloadCanceled() {
        self.portionOfDownloadProgressArea = 0.0
        adjustPropertiesToSublayersDuringDownload()
    }

}

