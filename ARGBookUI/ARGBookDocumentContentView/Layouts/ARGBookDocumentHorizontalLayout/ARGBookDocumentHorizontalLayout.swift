//
//  ARGBookDocumentHorizontalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentHorizontalLayout: ARGBookDocumentLayout {
    
    override var isReady: Bool {
        didSet {
            if self.webView.scrollView.contentSize.width > self.webView.scrollView.bounds.size.width {
                self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.settingsController as! ARGFlowableLayoutSettingsProvider).absolutePageMargins.horizontal)
            } else {
                self.webView.scrollView.contentInset = UIEdgeInsets()
            }
        }
    }
    
    override func prepare(completionHandler: (() -> Void)? = nil) {
        webView.scrollView.isPagingEnabled = true
        webView.scrollView.bounces = false
        super.prepare(completionHandler: completionHandler)
    }
    
    override class func settingsControllerClass<T: ARGBookReadingSettingsController>() -> T.Type {
        return ARGFlowableLayoutSettingsProvider.self as! T.Type
    }
    
    override func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {
        webView.arg_measure(.width) { measuredWidth, error in
            if let width = measuredWidth {
                completionHandler?(CGSize(width: width, height: self.webView.scrollView.bounds.height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    override func scroll(to element: String, completionHandler: (() -> Void)? = nil) {
        let script = "getHorizontalOffsetForElementID('\(element)')"
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let offset = result as? CGFloat {
                let page = floor(offset / self.webView.scrollView.bounds.width)
                self.webView.scrollView.contentOffset = CGPoint(x: page * self.webView.scrollView.bounds.width,
                                                                y: self.webView.scrollView.contentOffset.y)
            }
            
            completionHandler?()
        }
    }
    
    override func scroll(to position: CGFloat, completionHandler: (() -> Void)?) {
        let offset = position * (webView.scrollView.contentSize.width + webView.scrollView.contentInset.right - webView.scrollView.bounds.width)
        let page = floor(offset / self.webView.scrollView.bounds.width)
        self.webView.scrollView.contentOffset = CGPoint(x: page * self.webView.scrollView.bounds.width,
                                                        y: self.webView.scrollView.contentOffset.y)
        completionHandler?()
    }
    
    override func currentScrollPosition() -> CGFloat {
        return webView.scrollView.contentOffset.x / (webView.scrollView.contentSize.width + webView.scrollView.contentInset.right - webView.scrollView.bounds.width)
    }
    
    override class func pageCount(for contentSize: CGSize, viewPort: CGSize) -> UInt {
        return UInt(ceil(contentSize.width / viewPort.width))
    }
    
}
