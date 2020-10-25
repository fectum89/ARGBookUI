//
//  ARGBookDocumentHorizontalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentHorizontalLayout: ARGBookDocumentLayout {
    
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
                if width > self.webView.bounds.size.width {
                    self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.settingsController as! ARGFlowableLayoutSettingsProvider).absolutePageMargins.horizontal)
                } else {
                    self.webView.scrollView.contentInset = UIEdgeInsets()
                }
                
                completionHandler?(CGSize(width: width, height: self.webView.bounds.size.height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    override func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)?){
        switch navigationPoint {
        case is ARGBookDocumentStartNavigationPoint:
            self.webView.scrollView.contentOffset = CGPoint(x: 0, y: self.webView.scrollView.contentOffset.y)
            completionHandler?()
        case is ARGBookDocumentEndNavigationPoint:
            webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentSize.width + self.webView.scrollView.contentInset.right - webView.scrollView.bounds.size.width, y: webView.scrollView.contentOffset.y)
            completionHandler?()
        default:
            if let elementID = navigationPoint.elementID {
                let script = "getHorizontalOffsetForElementID('\(elementID)')"
                webView.evaluateJavaScript(script) { (result, error) in
                    if let offset = result as? CGFloat {
                        let page = floor(offset / self.webView.bounds.size.width)
                        self.webView.scrollView.contentOffset = CGPoint(x: page * self.webView.bounds.size.width,
                                                                        y: self.webView.scrollView.contentOffset.y)
                    }
                    completionHandler?()
                }
            } else {
                completionHandler?()
            }
            
        }
    }
    
}
