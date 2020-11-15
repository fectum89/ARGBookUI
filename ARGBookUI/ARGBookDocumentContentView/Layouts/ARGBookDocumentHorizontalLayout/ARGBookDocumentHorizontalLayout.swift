//
//  ARGBookDocumentHorizontalLayout.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit

class ARGBookDocumentHorizontalLayout: ARGBookDocumentSettingsControllerContainer {
    
    var webView: WKWebView
    
    var settingsController: ARGBookReadingSettingsController
    
    var isReady: Bool = false {
        didSet {
            if isReady {
                webView.scrollView.isPagingEnabled = true
                webView.scrollView.bounces = false
                
                if self.webView.scrollView.contentSize.width > self.webView.scrollView.bounds.size.width {
                    self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.settingsController as! ARGFlowableLayoutSettingsController).absolutePageMargins.horizontal)
                    webView.scrollView.isPagingEnabled = true
                } else {
                    self.webView.scrollView.contentInset = UIEdgeInsets()
                }
            }
        }
    }
    
    required init(webView: WKWebView) {
        self.webView = webView
        isReady = false
        self.settingsController = ARGFlowableLayoutSettingsController(webView: webView)
    }
    
    deinit {
        print("layout deinit")
    }
    
}

extension ARGBookDocumentHorizontalLayout: ARGBookDocumentScrollBehavior {
    
    func scroll(to element: String, completionHandler: (() -> Void)? = nil) {
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
    
    func scroll(to position: CGFloat, completionHandler: (() -> Void)?) {
        let contentSize = webView.scrollView.contentSize.width + webView.scrollView.contentInset.right
        let lastPageOffset = contentSize - webView.scrollView.bounds.width
        let offset = position * contentSize
        let page = floor(offset / self.webView.scrollView.bounds.width)
        self.webView.scrollView.contentOffset = CGPoint(x: min(page * self.webView.scrollView.bounds.width, lastPageOffset),
                                                        y: self.webView.scrollView.contentOffset.y)
        completionHandler?()
    }
    
    func currentScrollPosition() -> CGFloat {
        return webView.scrollView.contentOffset.x / (webView.scrollView.contentSize.width + webView.scrollView.contentInset.right)
    }
    
}

extension ARGBookDocumentHorizontalLayout: ARGBookDocumentContentSizeContainer {
    
    func measureContentSize(completionHandler: ((CGSize?) -> Void)? = nil) {
        webView.arg_measure(.width) { measuredWidth, error in
            if let width = measuredWidth {
                completionHandler?(CGSize(width: width, height: self.webView.scrollView.bounds.height))
            } else {
                completionHandler?(nil)
            }
        }
    }
    
    class func pageCount(for contentSize: CGSize, viewPort: CGSize) -> Int {
        return Int(ceil(contentSize.width / viewPort.width))
    }
    
}


extension ARGBookDocumentHorizontalLayout: ARGBookDocumentPageOverlayCreator {
    
    static func overlayView(parentView: UIView) -> ARGDocumentPageOverlayView {
        let nib = UINib(nibName: "ARGDocumentPageHorizontalOverlayView", bundle: Bundle(for: Self.self))
        let overlayView = nib.instantiate(withOwner: parentView, options: nil).first as! ARGDocumentPageOverlayView
        overlayView.frame = parentView.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parentView.addSubview(overlayView)
        return overlayView
    }
    
}
