//
//  ARGBookDocumentVerticalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentVerticalLayout: ARGBookDocumentLayout {
    
    override var isReady: Bool {
        didSet {
            let pages = Int(ceil(self.webView.scrollView.contentSize.height / self.webView.bounds.size.height))
            let inset = pages * Int(self.webView.bounds.size.height) % Int(self.webView.scrollView.contentSize.height)
            //self.webView.scrollView.contentSize = CGSize(width: self.webView.scrollView.contentSize.width, height: pages * self.webView.bounds.size.height)
            self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(inset), right: 0)
        }
    }
    
    override func prepare(completionHandler: (() -> Void)? = nil) {
        webView.scrollView.bounces = false
        webView.scrollView.isPagingEnabled = false
        webView.scrollView.contentInset = UIEdgeInsets()
        super.prepare(completionHandler: completionHandler)
    }
    
    override class func settingsControllerClass<T: ARGBookReadingSettingsController>() -> T.Type {
        return ARGBookVerticalLayoutSettingsController.self as! T.Type
    }
    
    override func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {
        webView.arg_measure(.height) { measuredHeight, error in
            if let height = measuredHeight {
                completionHandler?(CGSize(width: self.webView.bounds.size.width, height: height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    override func scroll(to navigationPoint: ARGBookNavigationPoint, completionHandler: (() -> Void)?){
        switch navigationPoint {
        case is ARGBookDocumentStartNavigationPoint:
            self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x, y: 0)
        case is ARGBookDocumentEndNavigationPoint:
            webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentOffset.x, y: webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom - webView.scrollView.bounds.size.height)
        default:
            if let elementID = navigationPoint.elementID {
                let script = "getVerticalOffsetForElementID('\(elementID)')"
               // print("scroll to: \(URL(fileURLWithPath: navigationPoint.document!.filePath).lastPathComponent) - \(navigationPoint.elementID)")
                webView.evaluateJavaScript(script) { (result, error) in
                    if let offset = result as? CGFloat {
                        self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x,
                                                                        y: offset)
                    }
                    completionHandler?()
                }
            } else {
                completionHandler?()
            }
        }
    }

}
