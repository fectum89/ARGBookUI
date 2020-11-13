//
//  ARGBookDocumentVerticalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentVerticalLayout: ARGBookDocumentSettingsControllerContainer {
    
    var webView: WKWebView
    
    var settingsController: ARGBookReadingSettingsController
    
    var isReady: Bool {
        didSet {
            if isReady {
                webView.scrollView.bounces = false
                webView.scrollView.isPagingEnabled = false
                webView.scrollView.contentInset = UIEdgeInsets()
                
                let pages = Int(ceil(self.webView.scrollView.contentSize.height / self.webView.bounds.size.height))
                let inset = pages * Int(self.webView.bounds.size.height) % Int(self.webView.scrollView.contentSize.height)
                self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: CGFloat(inset), right: 0)
            }
        }
    }
    
    required init(webView: WKWebView) {
        self.webView = webView
        isReady = false
        self.settingsController = ARGBookVerticalLayoutSettingsController(webView: webView)
    }

}

extension ARGBookDocumentVerticalLayout: ARGBookDocumentScrollBehavior {
    
    func scroll(to element: String, completionHandler: (() -> Void)? = nil) {
        let script = "getHorizontalOffsetForElementID('\(element)')"
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let offset = result as? CGFloat {
                self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x,
                                                                y: offset)
            }
            
            completionHandler?()
        }
    }
    
    func scroll(to position: CGFloat, completionHandler: (() -> Void)?) {
        let offset = position * (webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom - webView.scrollView.bounds.height)

        self.webView.scrollView.contentOffset = CGPoint(x: self.webView.scrollView.contentOffset.x,
                                                        y: offset)
        completionHandler?()
    }
    
    func currentScrollPosition() -> CGFloat {
        return webView.scrollView.contentOffset.y / (webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom - webView.scrollView.bounds.height)
    }
    
}

extension ARGBookDocumentVerticalLayout: ARGBookDocumentContentSizeContainer {

    func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {
        webView.arg_measure(.height) { measuredHeight, error in
            if let height = measuredHeight {
                completionHandler?(CGSize(width: self.webView.bounds.size.width, height: height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    static func pageCount(for contentSize: CGSize, viewPort: CGSize) -> Int {
        return Int(ceil(contentSize.height / viewPort.height))
    }
    
}
