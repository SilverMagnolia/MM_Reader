//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit


/**
 this struct is used to scale web view. 
 when pinch gesture is recognized, 
 the zooming in or zooming out are limited by the properties of this struct 
 according to the current font size.
 if scale value in .ended state is range of 0.95 ~ 1.5, nothing happens.
 */
internal struct ScaleInformation {
    
    let maxScaleToDoNothing: CGFloat
    let minScaleToDoNothing: CGFloat
    
    var maxScaleToZoomIn: CGFloat?
    var minScaleToZoomOut: CGFloat?
 
    init(){
        self.maxScaleToDoNothing = 1.5
        self.minScaleToDoNothing = 0.95
    }
    
    mutating func setMaxAndMinValue() {
        
        let curFontSize = FolioReader.currentFontSize
        
        switch(curFontSize) {
        case .xl:
            self.maxScaleToZoomIn = 1.25
            self.minScaleToZoomOut = 0.55
            break
        case .l:
            self.maxScaleToZoomIn = 1.5
            self.minScaleToZoomOut = 0.65
            break
        case .m:
            self.maxScaleToZoomIn = 2.5
            self.minScaleToZoomOut = 0.75
            break
        case .s:
            self.maxScaleToZoomIn = 3.5
            self.minScaleToZoomOut = 0.85
            break
        case .xs:
            self.maxScaleToZoomIn = 4.5
            self.minScaleToZoomOut = 0.95
            break
        }
    }
}

open class FolioReaderWebView: UIWebView, UIGestureRecognizerDelegate{

	var isColors = false
	var isShare = false
    var isOneWord = false
	// MARK: - UIMenuController

    // custom var
    var scaleInfo = ScaleInformation()
    var currentWebviewState: CGAffineTransform?
    var pinchScale: CGFloat?

    // custom func
    func setPinchRecognizer() {
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinchRecognizer.delegate = self
        self.addGestureRecognizer(pinchRecognizer)
        
        self.scalesPageToFit = false
        currentWebviewState = self.transform
    }

    // custom
    func handlePinchGesture(_ sender: UIPinchGestureRecognizer) {

        // .began
        if sender.state == .began {
            
            print("pinch began")
            self.scaleInfo.setMaxAndMinValue()
            self.currentWebviewState = self.transform
            self.pinchScale = 1.0
        
        // .changed
        } else if sender.state == .changed {
            
            if self.pinchScale! < scaleInfo.maxScaleToZoomIn! &&
                self.pinchScale! > scaleInfo.minScaleToZoomOut! {
                
                self.transform = self.transform.scaledBy(x: sender.scale, y: sender.scale)
                self.pinchScale = sender.scale * self.pinchScale!
                print("pinchScale: \(self.pinchScale)")
                sender.scale = 1.0
                
            }
            
        // .ended
        } else if sender.state == .ended {
            
            self.transform = self.currentWebviewState!
            
            if self.pinchScale! >= scaleInfo.maxScaleToDoNothing ||
                self.pinchScale! <= scaleInfo.minScaleToDoNothing {
                
                if !((FolioReader.currentFontSize == .xs && self.pinchScale! < 1) ||
                    (FolioReader.currentFontSize == .xl && self.pinchScale! > 1)) {
                    adjustFontSizeByPinchScale()
                    
                }
            } // END IF
            else {
                print("do nothing")
            }
        }// END ELSE IF
    }//END FUNC
    
    
    // custom
    func adjustFontSizeByPinchScale() {
        print("adjustFontSizeByPinchScale")
        var curFontSize:Int = FolioReader.currentFontSize.rawValue
        
        // size up
        if self.pinchScale! > 1.5 {
            
            if pinchScale! > (1.5 as CGFloat) && pinchScale! <= (2.5 as CGFloat) {
                curFontSize = curFontSize + 1
            } else if pinchScale! > (2.5 as CGFloat) && pinchScale! <= (3.5 as CGFloat) {
                curFontSize = curFontSize + 2
            } else if pinchScale! > (3.5 as CGFloat) && pinchScale! <= (4.5 as CGFloat) {
                curFontSize = curFontSize + 3
            } else {
                curFontSize = curFontSize + 4
            }
            
            //curFontSize = curFontSize + pinchScale
        // size down
        } else {
            if pinchScale! < (0.95 as CGFloat) && pinchScale! >= (0.85 as CGFloat) {
                curFontSize = curFontSize - 1
            } else if pinchScale! < (0.85 as CGFloat) && pinchScale! >= (0.75 as CGFloat) {
                curFontSize = curFontSize - 2
            } else if pinchScale! < (0.75 as CGFloat) && pinchScale! >= (0.65 as CGFloat) {
                curFontSize = curFontSize - 3
            } else if pinchScale! < (0.65 as CGFloat) && pinchScale! >= (0.55 as CGFloat){
                curFontSize = curFontSize - 4
            }
            
            if pinchScale! < scaleInfo.minScaleToZoomOut! {
                curFontSize = 0
            }
        }
        
        // adjust font size by pinch scale
        if let _fontSize = FolioReaderFontSize(rawValue: curFontSize){
            FolioReader.currentFontSize = _fontSize
        }
    }
    
    // custom
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
	open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		guard readerConfig != nil && readerConfig.useReaderMenuController == true else {
			return super.canPerformAction(action, withSender: sender)
		}
        
		if isShare {
			return false
		} else if isColors {
			return false
		} else {
			if action == #selector(highlight(_:))
				|| (action == #selector(define(_:)) && isOneWord)
                || (action == #selector(play(_:)) && (book.hasAudio() || readerConfig.enableTTS))
				|| (action == #selector(share(_:)) && readerConfig.allowSharing)
				|| (action == #selector(copy(_:)) && readerConfig.allowSharing) {
				return true
			}
			return false
		}
	}

	open override var canBecomeFirstResponder : Bool {
		return true
	}

	// MARK: - UIMenuController - Actions

	func share(_ sender: UIMenuController) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let shareImage = UIAlertAction(title: readerConfig.localizedShareImageQuote, style: .default, handler: { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.shared.readerCenter?.presentQuoteShare(textToShare)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.shared.readerCenter?.presentQuoteShare(textToShare)
					self.isUserInteractionEnabled = false
					self.isUserInteractionEnabled = true
				}
			}
			self.setMenuVisible(false)
		})

		let shareText = UIAlertAction(title: readerConfig.localizedShareTextQuote, style: .default) { (action) -> Void in
			if self.isShare {
				if let textToShare = self.js("getHighlightContent()") {
					FolioReader.shared.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			} else {
				if let textToShare = self.js("getSelectedText()") {
					FolioReader.shared.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
				}
			}
			self.setMenuVisible(false)
		}

		let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .cancel, handler: nil)

		alertController.addAction(shareImage)
		alertController.addAction(shareText)
		alertController.addAction(cancel)

        if let alert = alertController.popoverPresentationController {
            alert.sourceView = FolioReader.shared.readerCenter?.currentPage
            alert.sourceRect = sender.menuFrame
        }
        
		FolioReader.shared.readerCenter?.present(alertController, animated: true, completion: nil)
	}

	func colors(_ sender: UIMenuController?) {
		isColors = true
		createMenu(options: false)
		setMenuVisible(true)
	}

	func remove(_ sender: UIMenuController?) {
		if let removedId = js("removeThisHighlight()") {
			Highlight.removeById(removedId)
		}
		setMenuVisible(false)
	}

	func highlight(_ sender: UIMenuController?) {
		let highlightAndReturn = js("highlightString('\(HighlightStyle.classForStyle(FolioReader.currentHighlightStyle))')")
		let jsonData = highlightAndReturn?.data(using: String.Encoding.utf8)

		do {
			let json = try JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSArray
			let dic = json.firstObject as! [String: String]
			let rect = CGRectFromString(dic["rect"]!)
			let startOffset = dic["startOffset"]!
			let endOffset = dic["endOffset"]!

			// Force remove text selection
			isUserInteractionEnabled = false
			isUserInteractionEnabled = true

			createMenu(options: true)
			setMenuVisible(true, andRect: rect)

			// Persist
			let html = js("getHTML()")
			if let highlight = Highlight.matchHighlight(html, andId: dic["id"]!, startOffset: startOffset, endOffset: endOffset) {
				highlight.persist()
			}
		} catch {
			print("Could not receive JSON")
		}
	}

	func define(_ sender: UIMenuController?) {
		let selectedText = js("getSelectedText()")

		setMenuVisible(false)
		isUserInteractionEnabled = false
		isUserInteractionEnabled = true

		let vc = UIReferenceLibraryViewController(term: selectedText! )
		vc.view.tintColor = readerConfig.tintColor
		FolioReader.shared.readerContainer.show(vc, sender: nil)
	}

	func play(_ sender: UIMenuController?) {
		FolioReader.shared.readerAudioPlayer?.play()

		// Force remove text selection
		// @NOTE: this doesn't seem to always work
		isUserInteractionEnabled = false
		isUserInteractionEnabled = true
	}

	func setYellow(_ sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .yellow)
	}

	func setGreen(_ sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .green)
	}

	func setBlue(_ sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .blue)
	}

	func setPink(_ sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .pink)
	}

	func setUnderline(_ sender: UIMenuController?) {
		changeHighlightStyle(sender, style: .underline)
	}

	func changeHighlightStyle(_ sender: UIMenuController?, style: HighlightStyle) {
		FolioReader.currentHighlightStyle = style.rawValue

		if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
			Highlight.updateById(updateId, type: style)
		}
		colors(sender)
	}

	// MARK: - Create and show menu

	func createMenu(options: Bool) {
		guard readerConfig.useReaderMenuController else {
			return
		}

		isShare = options

		let colors = UIImage(readerImageNamed: "colors-marker")
		let share = UIImage(readerImageNamed: "share-marker")
		let remove = UIImage(readerImageNamed: "no-marker")
		let yellow = UIImage(readerImageNamed: "yellow-marker")
		let green = UIImage(readerImageNamed: "green-marker")
		let blue = UIImage(readerImageNamed: "blue-marker")
		let pink = UIImage(readerImageNamed: "pink-marker")
		let underline = UIImage(readerImageNamed: "underline-marker")

        let menuController = UIMenuController.shared
        
		let highlightItem = UIMenuItem(title: readerConfig.localizedHighlightMenu, action: #selector(highlight(_:)))
		let playAudioItem = UIMenuItem(title: readerConfig.localizedPlayMenu, action: #selector(play(_:)))
		let defineItem = UIMenuItem(title: readerConfig.localizedDefineMenu, action: #selector(define(_:)))
        let colorsItem = UIMenuItem(title: "C", image: colors) { [weak self] _ in
            self?.colors(menuController)
        }
        let shareItem = UIMenuItem(title: "S", image: share) { [weak self] _ in
            self?.share(menuController)
        }
        let removeItem = UIMenuItem(title: "R", image: remove) { [weak self] _ in
            self?.remove(menuController)
        }
        let yellowItem = UIMenuItem(title: "Y", image: yellow) { [weak self] _ in
            self?.setYellow(menuController)
        }
        let greenItem = UIMenuItem(title: "G", image: green) { [weak self] _ in
            self?.setGreen(menuController)
        }
        let blueItem = UIMenuItem(title: "B", image: blue) { [weak self] _ in
            self?.setBlue(menuController)
        }
        let pinkItem = UIMenuItem(title: "P", image: pink) { [weak self] _ in
            self?.setPink(menuController)
        }
        let underlineItem = UIMenuItem(title: "U", image: underline) { [weak self] _ in
            self?.setUnderline(menuController)
        }
        
        var menuItems = [shareItem]
        
        // menu on existing highlight
        if isShare {
            menuItems = [colorsItem, removeItem]
            if readerConfig.allowSharing {
                menuItems.append(shareItem)
            }
        } else if isColors {
            // menu for selecting highlight color
            menuItems = [yellowItem, greenItem, blueItem, pinkItem, underlineItem]
        } else {
            // default menu
            menuItems = [highlightItem, defineItem, shareItem]
            
            if book.hasAudio() || readerConfig.enableTTS {
                menuItems.insert(playAudioItem, at: 0)
            }
            
            if !readerConfig.allowSharing {
                menuItems.removeLast()
            }
        }
        
        menuController.menuItems = menuItems
	}

	func setMenuVisible(_ menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRect.zero) {
		if !menuVisible && isShare || !menuVisible && isColors {
			isColors = false
			isShare = false
		}

		if menuVisible  {
			if !rect.equalTo(CGRect.zero) {
				UIMenuController.shared.setTargetRect(rect, in: self)
			}
		}

		UIMenuController.shared.setMenuVisible(menuVisible, animated: animated)
	}

	// MARK: - Java Script Bridge

	func js(_ script: String) -> String? {
		let callback = self.stringByEvaluatingJavaScript(from: script)
		if callback!.isEmpty { return nil }
		return callback
	}

	// MARK: WebView direction config

	func setupScrollDirection() {
		switch readerConfig.scrollDirection {
		case .vertical, .horizontalWithVerticalContent:
			scrollView.isPagingEnabled = false
			paginationMode = .unpaginated
			scrollView.bounces = true
			break
		case .horizontal:
			scrollView.isPagingEnabled = true
			paginationMode = .leftToRight
			paginationBreakingMode = .page
			scrollView.bounces = false
			break
		}
	}
}
