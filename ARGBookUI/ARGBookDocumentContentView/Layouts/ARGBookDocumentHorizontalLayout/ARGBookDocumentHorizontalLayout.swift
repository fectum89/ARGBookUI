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
                
                if webView.scrollView.contentSize.width > webView.scrollView.bounds.size.width {
                    self.webView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (self.settingsController as! ARGFlowableLayoutSettingsController).absolutePageMargins.horizontal)
                } else {
                    webView.scrollView.contentInset = UIEdgeInsets()
                }
            }
        }
    }
    
    required init(webView: WKWebView) {
        self.webView = webView
        self.settingsController = ARGFlowableLayoutSettingsController(webView: webView)
    }
    
}

extension ARGBookDocumentHorizontalLayout: ARGBookDocumentScrollBehavior {
    
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
        let contentSize = webView.scrollView.contentSize.width + webView.scrollView.contentInset.right
        let lastPageOffset = contentSize - webView.scrollView.bounds.width
        let page = floor(toOffset / webView.scrollView.bounds.width)
        webView.scrollView.contentOffset = CGPoint(x: min(page * webView.scrollView.bounds.width, lastPageOffset),
                                                   y: webView.scrollView.contentOffset.y)
    }
    
    func scroll(to position: CGFloat) {
        let contentSize = webView.scrollView.contentSize.width + webView.scrollView.contentInset.right
        let offset = position * contentSize
        constrainedScroll(toOffset: offset)
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
    
    static func pageSize(for viewPort: CGSize, settings: ARGBookReadingSettings,sizeClass: UIUserInterfaceSizeClass) -> CGSize {
        var pageWidth: CGFloat
        
        if (sizeClass == .regular && viewPort.width > viewPort.height && settings.twoColumnsLayout) {
            pageWidth = viewPort.width / 2
        } else {
            pageWidth = viewPort.width
        }
        
        return CGSize(width: pageWidth, height: viewPort.height)
    }
    
    class func pageCount(for contentSize: CGSize, pageSize: CGSize) -> Int {
        return Int(ceil(contentSize.width / pageSize.width))
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
