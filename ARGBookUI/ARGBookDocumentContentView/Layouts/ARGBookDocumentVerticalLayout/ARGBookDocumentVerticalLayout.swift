//
//  ARGBookDocumentVerticalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit

class ARGBookDocumentVerticalLayout: ARGBookDocumentSettingsControllerContainer {
    
    var webView: WKWebView
    
    var settingsController: ARGBookReadingSettingsController
    
    var isReady: Bool = false {
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
        self.settingsController = ARGBookVerticalLayoutSettingsController(webView: webView)
    }

}

extension ARGBookDocumentVerticalLayout: ARGBookDocumentScrollBehavior {

    func scroll(to element: String, completionHandler: (() -> Void)? = nil) {
        let script = "getHorizontalOffsetForElementID('\(element)')"
        
        webView.evaluateJavaScript(script) { (result, error) in
            if let offset = result as? CGFloat {
                self.constrainedScroll(toOffset: offset)
            }
            
            completionHandler?()
        }
    }
    
    func constrainedScroll(toOffset: CGFloat) {
        let contentSize = webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom
        let lastPageOffset = contentSize - webView.scrollView.bounds.height
        let page = floor(toOffset / webView.scrollView.bounds.height)
        
        webView.scrollView.contentOffset = CGPoint(x: webView.scrollView.contentOffset.x,
                                                   y: min(page * webView.scrollView.bounds.height, lastPageOffset))
    }
    
    func scroll(to position: CGFloat) {
        let contentSize = webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom
        let offset = position * contentSize
        constrainedScroll(toOffset: offset)
    }
    
    func currentScrollPosition() -> CGFloat {
        return webView.scrollView.contentOffset.y / (webView.scrollView.contentSize.height + webView.scrollView.contentInset.bottom)
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
    
    static func pageCount(for contentSize: CGSize, pageSize: CGSize) -> Int {
        return Int(ceil(contentSize.height / pageSize.height))
    }
    
}

extension ARGBookDocumentVerticalLayout: ARGBookDocumentPageOverlayCreator {
    
    static func overlayView(parentView: UIView) -> ARGDocumentPageOverlayView {
        let nib = UINib(nibName: "ARGDocumentPageVerticalOverlayView", bundle: Bundle(for: Self.self))
        let overlayView = nib.instantiate(withOwner: parentView, options: nil).first as! ARGDocumentPageOverlayView
        overlayView.frame = parentView.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(overlayView)
        return overlayView
    }
    
}
