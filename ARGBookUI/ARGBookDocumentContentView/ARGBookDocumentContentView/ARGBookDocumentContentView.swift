//
//  ARGBookDocumentContentView.swift
//  ARGBookUI
//
//  Created by Sergei Polshcha on 10.10.2020.
//

import UIKit
import WebKit

class ARGBookDocumentContentView: UIView {
    
    var webView: WKWebView!
    
    var documentLoader: ARGBookDocumentLoader!
    var layout: ARGBookDocumentLayout?
    
    var navigationPoint: ARGBookNavigationPoint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let configuration = ARGBookWebViewConfigurator.configuration()
        
        webView = WKWebView(frame: frame, configuration: configuration)
        
        webView.frame = bounds
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.clipsToBounds = true
        webView.navigationDelegate = self
        
        addSubview(webView)
        
        documentLoader = ARGBookDocumentLoader(webView: webView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadIfNeeded(document: ARGBookDocument, settings: ARGBookReadingSettings, completion: (() -> Void)? = nil) {
        let LayoutClass = ARGBookDocumentLayout.documentLayoutClass(for: document, scrollType: settings.scrollType)
        
        if self.layout == nil || type(of: self.layout) != LayoutClass {
            self.layout = LayoutClass.init(webView: self.webView)
        }
        
        documentLoader.loadDocumentIfNeeded(document) { error in
            self.applyReadingSettings(settings) {
                completion?()
            }
        }
    }
    
    func scroll(to navigationPoint: ARGBookNavigationPoint) {
        if !self.layout!.scroll(to: navigationPoint) {
            //save navigation point to scroll to it later
            self.navigationPoint = navigationPoint
        }
    }
    
    func applyReadingSettings(_ settings: ARGBookReadingSettings, completionHandler: (() -> Void)? = nil) {
        self.layout?.applyReadingSettings(settings) {
            let _ = self.layout?.scroll(to: self.navigationPoint, completionHandler: completionHandler)
        }
    }
    
}

extension ARGBookDocumentContentView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        documentLoader.webView(webView, didFinish: navigation)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        documentLoader.webView(webView, didFail: navigation, withError: error)
    }
    
}
